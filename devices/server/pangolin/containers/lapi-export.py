#!/usr/bin/env python3
import json
import os
import re
import threading
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

CREDENTIALS_PATH = os.environ.get("LAPI_CREDENTIALS_PATH", "/etc/crowdsec/local_api_credentials.yaml")
LAPI_URL = os.environ.get("LAPI_URL", "")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "6061"))
CACHE_TTL = int(os.environ.get("CACHE_TTL", "30"))
ALERTS_SINCE = os.environ.get("ALERTS_SINCE", "24h")
ALERTS_LIMIT = int(os.environ.get("ALERTS_LIMIT", "1000"))

_lock = threading.Lock()
_token = None
_cache = {}

DURATION_RE = re.compile(r"(?:(\d+)h)?(?:(\d+)m)?(?:([\d.]+)s)?")


def load_credentials():
    creds = {}
    with open(CREDENTIALS_PATH) as f:
        for line in f:
            if ":" in line:
                key, value = line.split(":", 1)
                creds[key.strip()] = value.strip()
    return LAPI_URL or creds["url"], creds["login"], creds["password"]


def login():
    url, machine_id, password = load_credentials()
    req = urllib.request.Request(
        url + "/v1/watchers/login",
        data=json.dumps({"machine_id": machine_id, "password": password}).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return url, json.load(resp)["token"]


def lapi_get(path):
    global _token
    url, _, _ = load_credentials()
    for attempt in range(2):
        if _token is None:
            _, _token = login()
        req = urllib.request.Request(url + path, headers={"Authorization": "Bearer " + _token})
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                body = resp.read()
                return json.loads(body) if body else None
        except urllib.error.HTTPError as e:
            if e.code == 401 and attempt == 0:
                _token = None
                continue
            raise
    raise RuntimeError("unreachable")


def duration_seconds(text):
    sign = -1 if text.startswith("-") else 1
    m = DURATION_RE.match(text.lstrip("-"))
    if not m:
        return 0
    h, mi, s = m.groups()
    return sign * int(int(h or 0) * 3600 + int(mi or 0) * 60 + float(s or 0))


def country_flag(cn):
    if not cn or len(cn) != 2 or not cn.isalpha():
        return ""
    return "".join(chr(0x1F1E6 + ord(c) - ord("A")) for c in cn.upper())


def event_paths(alert):
    paths = []
    latest = ""
    for event in alert.get("events") or []:
        meta = {m.get("key", ""): m.get("value", "") for m in event.get("meta") or []}
        if meta.get("http_path"):
            latest = (meta.get("http_verb", "") + " " + meta["http_path"]).strip()
            if meta["http_path"] not in paths:
                paths.append(meta["http_path"])
    return latest, paths


def flatten_bans():
    rows = []
    for alert in lapi_get("/v1/alerts?has_active_decision=true&include_capi=false&limit=500"):
        source = alert.get("source") or {}
        last_path, paths = event_paths(alert)
        for decision in alert.get("decisions") or []:
            remaining = duration_seconds(decision.get("duration", "0s"))
            if remaining <= 0:
                continue
            country = source.get("cn", "")
            rows.append({
                "ip": decision.get("value", ""),
                "country": (country_flag(country) + " " + country).strip(),
                "as_name": source.get("as_name", ""),
                "reason": decision.get("scenario", alert.get("scenario", "")),
                "last_target": last_path,
                "targets": ", ".join(paths[:5]),
                "events": alert.get("events_count", 0),
                "action": decision.get("type", ""),
                "origin": decision.get("origin", ""),
                "banned_at": alert.get("created_at", ""),
                "expires_in": remaining,
            })
    rows.sort(key=lambda r: r["expires_in"], reverse=True)
    return rows


def flatten_alerts():
    rows = []
    for alert in lapi_get(f"/v1/alerts?since={ALERTS_SINCE}&include_capi=false&limit={ALERTS_LIMIT}"):
        source = alert.get("source") or {}
        last_path, paths = event_paths(alert)
        country = source.get("cn", "")
        decisions = alert.get("decisions") or []
        rows.append({
            "time": alert.get("created_at", ""),
            "ip": source.get("value") or source.get("ip", ""),
            "country": (country_flag(country) + " " + country).strip(),
            "as_name": source.get("as_name", ""),
            "scenario": alert.get("scenario", ""),
            "last_target": last_path,
            "targets": ", ".join(paths[:5]),
            "events": alert.get("events_count", 0),
            "decision": decisions[0].get("type", "") if decisions else "none",
        })
    rows.sort(key=lambda r: r["time"], reverse=True)
    return rows


def cached(name, fn):
    now = time.time()
    with _lock:
        entry = _cache.get(name)
        if entry and now - entry[0] < CACHE_TTL:
            return entry[1]
    data = fn()
    with _lock:
        _cache[name] = (time.time(), data)
    return data


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        route = self.path.split("?")[0].rstrip("/")
        try:
            if route == "/bans":
                body = json.dumps(cached("bans", flatten_bans))
            elif route == "/alerts":
                body = json.dumps(cached("alerts", flatten_alerts))
            elif route == "/stats":
                body = json.dumps({
                    "active_bans": len(cached("bans", flatten_bans)),
                    "alerts_24h": len(cached("alerts", flatten_alerts)),
                })
            elif route == "/healthz":
                lapi_get("/v1/heartbeat")
                body = json.dumps({"status": "ok"})
            else:
                self.send_error(404)
                return
        except Exception as e:
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode())
            return
        payload = body.encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", LISTEN_PORT), Handler).serve_forever()
