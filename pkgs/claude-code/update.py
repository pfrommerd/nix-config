#!/usr/bin/env -S uv run --script

import json
import sys
import urllib.request
from pathlib import Path

BASE_URL = "https://downloads.claude.ai/claude-code-releases"
MANIFEST_PATH = Path(__file__).parent / "manifest.json"


def fetch_latest_version() -> str:
    with urllib.request.urlopen(f"{BASE_URL}/latest") as response:
        return response.read().decode().strip()


def fetch_manifest(version: str) -> dict:
    with urllib.request.urlopen(f"{BASE_URL}/{version}/manifest.json") as response:
        return json.loads(response.read().decode())


def read_current_version() -> str | None:
    if not MANIFEST_PATH.exists():
        return None
    with open(MANIFEST_PATH, "r") as f:
        return json.load(f).get("version")


def update():
    current = read_current_version()
    latest = sys.argv[1] if len(sys.argv) > 1 else fetch_latest_version()
    if current == latest:
        print("claude-code is up to date!")
        return

    print(f"Updating claude-code: {current or 'unknown'} -> {latest}")
    manifest = fetch_manifest(latest)
    if manifest.get("version") != latest:
        raise RuntimeError(
            f"Manifest version {manifest.get('version')!r} does not match {latest!r}"
        )

    with open(MANIFEST_PATH, "w") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")

    print(f"Wrote {MANIFEST_PATH}")


if __name__ == "__main__":
    update()
