#!/usr/bin/env -S uv run --script

import json
import re
import subprocess
import urllib.request
from pathlib import Path

INSTALLER_URL = "https://cursor.com/install"
SOURCES_PATH = Path(__file__).parent / "sources.json"

PLATFORMS = {
    "x86_64-linux": ("linux", "x64"),
    "aarch64-linux": ("linux", "arm64"),
    "x86_64-darwin": ("darwin", "x64"),
    "aarch64-darwin": ("darwin", "arm64"),
}

DOWNLOAD_RE = re.compile(
    r"https://downloads\.cursor\.com/lab/(?P<version>[^/]+)/\$\{OS\}/\$\{ARCH\}/agent-cli-package\.tar\.gz"
)


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
    with urllib.request.urlopen(INSTALLER_URL) as response:
        script = response.read().decode()
    match = DOWNLOAD_RE.search(script)
    if not match:
        raise RuntimeError(
            f"Could not find agent CLI download URL in installer script at {INSTALLER_URL}"
        )
    return match.group("version")


def read_current_version() -> str | None:
    if not SOURCES_PATH.exists():
        return None
    with open(SOURCES_PATH, "r") as f:
        return json.load(f).get("version")


def update():
    current = read_current_version()
    latest = fetch_latest_version()
    if current == latest:
        print("cursor-cli is up to date!")
        return

    print(f"Updating cursor-cli: {current or 'unknown'} -> {latest}")
    sources: dict[str, dict[str, str]] = {}

    for platform, (os_name, arch) in PLATFORMS.items():
        url = f"https://downloads.cursor.com/lab/{latest}/{os_name}/{arch}/agent-cli-package.tar.gz"
        hash_sri = prefetch_sri(url, name=f"cursor-cli-{platform}-{latest}.tar.gz")
        sources[platform] = {"url": url, "hash": hash_sri}

    out = {"version": latest, "sources": sources}
    with open(SOURCES_PATH, "w") as f:
        json.dump(out, f, indent=2)
        f.write("\n")

    print(f"Wrote {SOURCES_PATH}")


if __name__ == "__main__":
    update()
