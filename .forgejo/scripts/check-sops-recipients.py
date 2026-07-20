#!/usr/bin/env python3
"""Check every secret's baked-in recipients against .sops.yaml, and that each
host can actually decrypt what it declares."""

import json
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SECRETS = REPO / "secrets"

# reported, not fatal; drop an entry once its key lands
WAIVED_HOSTS = {
    "mongoose": "pending re-provision"
}


def nix_json(*args):
    return json.loads(subprocess.run(
        args, cwd=REPO, stdout=subprocess.PIPE, text=True, check=True).stdout)


def load_sops_yaml():
    text = (REPO / ".sops.yaml").read_text()
    # scrape anchors first, yq resolves the aliases away
    anchors = dict(re.findall(r"-\s+&(\S+)\s+(age1\S+)", text))
    doc = nix_json("nix", "run", "--inputs-from", ".", "nixpkgs-unstable#yq-go",
                   "--", "-o=json", ".", ".sops.yaml")

    rules = [(re.compile(rule["path_regex"]),
              {k for g in rule.get("key_groups", []) for k in g.get("age", [])})
             for rule in doc.get("creation_rules", [])]
    return anchors, rules


def expected_recipients(path, rules):
    # sops is first-match-wins on an unanchored search
    rel = f"secrets/{path.name}"
    for pattern, keys in rules:
        if pattern.search(rel):
            return keys
    return None


def actual_recipients(path):
    return {e["recipient"] for e in json.loads(path.read_text())["sops"]["age"]}


def host_secret_map():
    raw = nix_json(
        "nix", "eval", "--json", ".#nixosConfigurations", "--apply",
        "builtins.mapAttrs (_: c: builtins.mapAttrs (_: v: v.sopsFile) c.config.sops.secrets)")
    return {host: {n: sf.split("/secrets/", 1)[1]
                   for n, sf in secrets.items() if "/secrets/" in sf}
            for host, secrets in raw.items()}


def main():
    anchors, rules = load_sops_yaml()
    failures, warnings = [], []
    recipients = {}

    # not woried about pub keys 
    for path in sorted(p for p in SECRETS.iterdir()
                       if p.is_file() and p.suffix != ".pub"):
        try:
            recipients[path.name] = actual = actual_recipients(path)
        except (json.JSONDecodeError, KeyError) as exc:
            recipients[path.name] = None
            failures.append(f"{path.name}: not a readable sops file ({exc})")
            continue

        expected = expected_recipients(path, rules)
        if expected is None:
            failures.append(f"{path.name}: no creation_rule matches")
        elif actual != expected:
            failures.append(
                f"{path.name}: recipients differ from .sops.yaml\n"
                f"    only in file:       {sorted(actual - expected) or '-'}\n"
                f"    only in .sops.yaml: {sorted(expected - actual) or '-'}\n"
                f"    fix: sops updatekeys secrets/{path.name}")

    for host, secrets in sorted(host_secret_map().items()):
        if not secrets:
            continue
        key = anchors.get(host)
        if key is None:
            msg = f"{host}: no key in .sops.yaml, but declares {len(secrets)} secret(s)"
            if host in WAIVED_HOSTS:
                warnings.append(f"{msg}\n    waived: {WAIVED_HOSTS[host]}")
            else:
                failures.append(
                    f"{msg}\n    fix: add its age key to .sops.yaml, then "
                    f"sops updatekeys on: {', '.join(sorted(set(secrets.values())))}")
            continue

        for name, filename in sorted(secrets.items()):
            if filename not in recipients:
                failures.append(f"{host}: secret {name} points at missing secrets/{filename}")
            elif recipients[filename] is not None and key not in recipients[filename]:
                failures.append(
                    f"{host}: cannot decrypt secrets/{filename} (declared as '{name}')\n"
                    f"    fix: sops updatekeys secrets/{filename}")

    for w in warnings:
        print(f"WARN  {w}")
    for f in failures:
        print(f"FAIL  {f}")

    if failures:
        print(f"\n{len(failures)} problem(s) found.")
        return 1
    print(f"OK: {len(recipients)} secrets match .sops.yaml, "
          f"every host can decrypt what it declares"
          f"{f' ({len(warnings)} waived)' if warnings else ''}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
