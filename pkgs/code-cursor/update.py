#!/usr/bin/env -S uv run --script

import json
import re
import subprocess
import urllib.request
from pathlib import Path

PLATFORMS = {
    "x86_64-linux": "linux-x64",
    "aarch64-linux": "linux-arm64",
    "x86_64-darwin": "darwin-x64",
    "aarch64-darwin": "darwin-arm64",
}


def fetch_hash(url, platform, version):
    hash = (
        subprocess.run(
            [
                "nix-prefetch-url",
                url,
                "--name",
                f"cursor-{platform}-{version}-appimage",
            ],
            stdout=subprocess.PIPE,
            stderr=None,
            check=True,
        )
        .stdout.decode()
        .strip()
    )
    hash = (
        subprocess.run(
            ["nix-hash", "--to-sri", "--type", "sha256", hash],
            stdout=subprocess.PIPE,
            stderr=None,
            check=True,
        )
        .stdout.decode()
        .strip()
    )
    return hash


def update():
    path = Path(__file__).parent / "sources.json"
    if path.exists():
        with open(path, "r") as f:
            curr_version = json.load(f).get("version", None)
    else:
        curr_version = None
    url_hashes = {}
    version = None
    for platform, api_platform in PLATFORMS.items():
        url_api = (
            f"https://api2.cursor.sh/updates/api/download/stable/{api_platform}/cursor"
        )
        with urllib.request.urlopen(url_api) as response:
            res = json.loads(response.read().decode())
        if version is None:
            version = res["version"]
            if version == curr_version:
                print("cursor is up to date!")
                return
        elif version != res["version"]:
            raise ValueError("inconsistent versions between platforms")
        url = res["downloadUrl"]
        hash = fetch_hash(url, platform, version)
        url_hashes[platform] = {"url": url, "hash": hash}

    sources = {
      "version": version,
      "vscodeVersion": "1.105.1",
      "sources": {
          platform: info for platform, info in url_hashes.items()
      }
    }
    with open(path, "w") as f:
        json.dump(sources, f, indent=2)

if __name__ == "__main__":
    update()
