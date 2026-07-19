#!/usr/bin/env -S uv run --script

import json
import subprocess
import urllib.request
from pathlib import Path

GITHUB_OWNER = "anomalyco"
GITHUB_REPO = "opencode"
RELEASES_URL = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases/latest"
SOURCES_PATH = Path(__file__).parent / "sources.json"

# Nix system -> release asset basename
PLATFORMS = {
    "x86_64-linux": "opencode-linux-x64.tar.gz",
    "aarch64-linux": "opencode-linux-arm64.tar.gz",
    "x86_64-darwin": "opencode-darwin-x64.zip",
    "aarch64-darwin": "opencode-darwin-arm64.zip",
}


def to_sri(hash_hex_or_b32: str) -> str:
    return subprocess.run(
        ["nix-hash", "--to-sri", "--type", "sha256", hash_hex_or_b32],
        stdout=subprocess.PIPE,
        stderr=None,
        check=True,
        text=True,
    ).stdout.strip()


def prefetch_sri(url: str, *, name: str) -> str:
    raw = subprocess.run(
        ["nix-prefetch-url", url, "--name", name],
        stdout=subprocess.PIPE,
        stderr=None,
        check=True,
        text=True,
    ).stdout.strip()
    return to_sri(raw)


def fetch_latest_version() -> str:
    req = urllib.request.Request(
        RELEASES_URL, headers={"Accept": "application/vnd.github+json"}
    )
    with urllib.request.urlopen(req) as response:
        tag = json.loads(response.read().decode())["tag_name"]
    if not tag.startswith("v"):
        raise RuntimeError(f"Unexpected tag format: {tag}")
    return tag.removeprefix("v")


def read_current_version() -> str | None:
    if not SOURCES_PATH.exists():
        return None
    with open(SOURCES_PATH, "r") as f:
        return json.load(f).get("version")


def update():
    current = read_current_version()
    latest = fetch_latest_version()
    if current == latest:
        print("opencode is up to date!")
        return

    print(f"Updating opencode: {current or 'unknown'} -> {latest}")
    base = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/releases/download/v{latest}"
    sources: dict[str, dict[str, str]] = {}

    for platform, asset in PLATFORMS.items():
        url = f"{base}/{asset}"
        hash_sri = prefetch_sri(url, name=f"opencode-{platform}-{latest}")
        sources[platform] = {"url": url, "hash": hash_sri}

    out = {"version": latest, "sources": sources}
    with open(SOURCES_PATH, "w") as f:
        json.dump(out, f, indent=2)
        f.write("\n")

    print(f"Wrote {SOURCES_PATH}")


if __name__ == "__main__":
    update()
