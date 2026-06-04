#!/usr/bin/env -S uv run --script

import json
import subprocess
import tarfile
import tempfile
import urllib.request
from io import BytesIO
from pathlib import Path

GITHUB_OWNER = "earendil-works"
GITHUB_REPO = "pi"
TAGS_URL = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/tags"
SOURCES_PATH = Path(__file__).parent / "sources.json"


def fetch_latest_version() -> str:
    with urllib.request.urlopen(TAGS_URL) as response:
        tags = json.loads(response.read().decode())
    if not tags:
        raise RuntimeError(f"No tags found for {GITHUB_OWNER}/{GITHUB_REPO}")
    tag = tags[0]["name"]
    if not tag.startswith("v"):
        raise RuntimeError(f"Unexpected tag format: {tag}")
    return tag.removeprefix("v")


def read_current_version() -> str | None:
    if not SOURCES_PATH.exists():
        return None
    with open(SOURCES_PATH, "r") as f:
        return json.load(f).get("version")


def prefetch_github(version: str) -> str:
    result = subprocess.run(
        [
            "nix",
            "run",
            "nixpkgs#nix-prefetch-github",
            "--",
            GITHUB_OWNER,
            GITHUB_REPO,
            "--rev",
            f"v{version}",
            "--json",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
        text=True,
    )
    return json.loads(result.stdout)["hash"]


def prefetch_npm_deps(version: str) -> str:
    tarball_url = (
        f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/archive/refs/tags/v{version}.tar.gz"
    )
    with urllib.request.urlopen(tarball_url) as response:
        tarball = tarfile.open(fileobj=BytesIO(response.read()), mode="r:gz")

    with tempfile.TemporaryDirectory() as tmp:
        tarball.extractall(tmp, filter="data")
        extracted = next(Path(tmp).iterdir())
        lockfile = extracted / "package-lock.json"
        if not lockfile.exists():
            raise RuntimeError(f"package-lock.json not found in v{version} source")

        result = subprocess.run(
            ["nix", "run", "nixpkgs#prefetch-npm-deps", "--", str(lockfile)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
            text=True,
        )
        for line in result.stdout.splitlines():
            line = line.strip()
            if line.startswith("sha256-"):
                return line
        raise RuntimeError("prefetch-npm-deps did not return a hash")


def update():
    current = read_current_version()
    latest = fetch_latest_version()
    if current == latest:
        print("pi-coding-agent is up to date!")
        return

    print(f"Updating pi-coding-agent: {current or 'unknown'} -> {latest}")
    src_hash = prefetch_github(latest)
    npm_deps_hash = prefetch_npm_deps(latest)

    out = {
        "version": latest,
        "srcHash": src_hash,
        "npmDepsHash": npm_deps_hash,
    }
    with open(SOURCES_PATH, "w") as f:
        json.dump(out, f, indent=2)
        f.write("\n")

    print(f"Wrote {SOURCES_PATH}")


if __name__ == "__main__":
    update()
