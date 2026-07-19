#!/usr/bin/env -S uv run --script

import json
import re
import subprocess
import urllib.request
from pathlib import Path

GITHUB_OWNER = "openai"
GITHUB_REPO = "codex"
RELEASES_URL = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases?per_page=100"
SOURCES_PATH = Path(__file__).parent / "sources.json"

# codex publishes many component tags; only the CLI uses `rust-vX.Y.Z`.
TAG_RE = re.compile(r"^rust-v(\d+\.\d+\.\d+)$")

# Nix system -> release asset target triple
PLATFORMS = {
    "x86_64-linux": "codex-x86_64-unknown-linux-musl.tar.gz",
    "aarch64-linux": "codex-aarch64-unknown-linux-musl.tar.gz",
    "x86_64-darwin": "codex-x86_64-apple-darwin.tar.gz",
    "aarch64-darwin": "codex-aarch64-apple-darwin.tar.gz",
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
        releases = json.loads(response.read().decode())
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue
        match = TAG_RE.match(release.get("tag_name", ""))
        if match:
            return match.group(1)
    raise RuntimeError("No rust-v* release found for openai/codex")


def read_current_version() -> str | None:
    if not SOURCES_PATH.exists():
        return None
    with open(SOURCES_PATH, "r") as f:
        return json.load(f).get("version")


def update():
    current = read_current_version()
    latest = fetch_latest_version()
    if current == latest:
        print("codex is up to date!")
        return

    print(f"Updating codex: {current or 'unknown'} -> {latest}")
    base = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/releases/download/rust-v{latest}"
    sources: dict[str, dict[str, str]] = {}

    for platform, asset in PLATFORMS.items():
        url = f"{base}/{asset}"
        hash_sri = prefetch_sri(url, name=f"codex-{platform}-{latest}")
        sources[platform] = {"url": url, "hash": hash_sri}

    out = {"version": latest, "sources": sources}
    with open(SOURCES_PATH, "w") as f:
        json.dump(out, f, indent=2)
        f.write("\n")

    print(f"Wrote {SOURCES_PATH}")


if __name__ == "__main__":
    update()
