#!/usr/bin/env python3
import json
import os
import re
import threading
import time
import urllib.error
import urllib.request
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

CREDENTIALS_PATH = os.environ.get("LAPI_CREDENTIALS_PATH", "/etc/crowdsec/local_api_credentials.yaml")
LAPI_URL = os.environ.get("LAPI_URL", "")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "6061"))
CACHE_TTL = int(os.environ.get("CACHE_TTL", "30"))
ALERTS_SINCE = os.environ.get("ALERTS_SINCE", "24h")
ALERTS_LIMIT = int(os.environ.get("ALERTS_LIMIT", "5000"))

_lock = threading.Lock()
_token = None
_cache = {}

DURATION_RE = re.compile(r"(\d+(?:\.\d+)?)(h|ms|m|µs|us|ns|s)")
DURATION_UNITS = {"h": 3600, "m": 60, "s": 1, "ms": 1e-3, "µs": 1e-6, "us": 1e-6, "ns": 1e-9}


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
    total = sum(float(value) * DURATION_UNITS[unit] for value, unit in DURATION_RE.findall(text))
    return sign * int(total)


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
    for alert in lapi_get("/v1/alerts?has_active_decision=true&include_capi=false&limit=500") or []:
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


def flatten_alerts(since):
    rows = []
    for alert in lapi_get(f"/v1/alerts?since={since}&include_capi=false&limit={ALERTS_LIMIT}") or []:
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


def alert_epoch(text):
    try:
        return datetime.fromisoformat(re.sub(r"\.\d+", "", text)).timestamp()
    except ValueError:
        return 0.0


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


def get_alerts(from_ts, to_ts):
    if from_ts is None:
        return cached("alerts:" + ALERTS_SINCE, lambda: flatten_alerts(ALERTS_SINCE))
    # round the LAPI window up to a whole minute so dashboard refreshes share a cache entry
    seconds = max(int(time.time()) - from_ts + 59, 60) // 60 * 60
    since = f"{seconds}s"
    rows = cached("alerts:" + since, lambda: flatten_alerts(since))
    to_limit = to_ts if to_ts is not None else time.time()
    return [r for r in rows if from_ts <= alert_epoch(r["time"]) <= to_limit]


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        route = parsed.path.rstrip("/")
        query = parse_qs(parsed.query)

        def int_param(name):
            try:
                return int(query.get(name, [""])[0])
            except ValueError:
                return None

        from_ts, to_ts = int_param("from"), int_param("to")
        try:
            if route == "/bans":
                body = json.dumps(cached("bans", flatten_bans))
            elif route == "/alerts":
                body = json.dumps(get_alerts(from_ts, to_ts))
            elif route == "/stats":
                bans = cached("bans", flatten_bans)
                body = json.dumps({
                    "active_bans": len(bans),
                    "banned_ips": len({row["ip"] for row in bans}),
                    "alerts": len(get_alerts(from_ts, to_ts)),
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
