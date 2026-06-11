#!/usr/bin/env -S uv run --script

import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

GITHUB_OWNER = "zed-industries"
GITHUB_REPO = "zed"
RELEASES_URL = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/releases"
PACKAGE_DIR = Path(__file__).resolve().parent
REPO_ROOT = PACKAGE_DIR.parent.parent
SOURCES_PATH = PACKAGE_DIR / "sources.json"
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
HASH_MISMATCH_RE = re.compile(r"got:\s+(sha256-[A-Za-z0-9+/=]+)")


def run(command: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=REPO_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=check,
        text=True,
    )


def fetch_latest_version() -> str:
    request = urllib.request.Request(
        f"{RELEASES_URL}?per_page=100",
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "zed-editor-nix-updater",
        },
    )
    with urllib.request.urlopen(request) as response:
        releases = json.load(response)

    for release in releases:
        tag = release["tag_name"]
        version = tag.removeprefix("v")
        if (
            tag.startswith("v")
            and not release["draft"]
            and not release["prerelease"]
            and "-pre" not in version
            and version not in {"0.999999.0", "0.9999-temporary"}
        ):
            return version

    raise RuntimeError(f"No stable release found for {GITHUB_OWNER}/{GITHUB_REPO}")


def read_sources() -> dict[str, str]:
    with open(SOURCES_PATH) as f:
        return json.load(f)


def write_sources(sources: dict[str, str]) -> None:
    with open(SOURCES_PATH, "w") as f:
        json.dump(sources, f, indent=2)
        f.write("\n")


def prefetch_source(version: str) -> str:
    result = run(
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
        ]
    )
    return json.loads(result.stdout)["hash"]


def prefetch_cargo_hash(version: str, src_hash: str) -> str:
    write_sources(
        {
            "version": version,
            "srcHash": src_hash,
            "cargoHash": FAKE_HASH,
        }
    )

    system = run(["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]).stdout
    result = run(
        [
            "nix",
            "build",
            "--no-link",
            f".#legacyPackages.{system}.zed-editor.cargoDeps",
        ],
        check=False,
    )
    output = result.stdout + result.stderr
    match = HASH_MISMATCH_RE.search(output)
    if not match:
        raise RuntimeError(
            "Could not determine cargoHash from the Cargo dependencies build:\n" + output
        )
    return match.group(1)


def update() -> None:
    current = read_sources()
    latest = fetch_latest_version()
    if current.get("version") == latest:
        print("zed-editor is up to date!")
        return

    print(f"Updating zed-editor: {current.get('version', 'unknown')} -> {latest}")
    try:
        src_hash = prefetch_source(latest)
        cargo_hash = prefetch_cargo_hash(latest, src_hash)
        write_sources(
            {
                "version": latest,
                "srcHash": src_hash,
                "cargoHash": cargo_hash,
            }
        )
    except Exception:
        write_sources(current)
        raise

    print(f"Wrote {SOURCES_PATH}")


if __name__ == "__main__":
    try:
        update()
    except subprocess.CalledProcessError as error:
        if error.stdout:
            print(error.stdout, file=sys.stderr, end="")
        if error.stderr:
            print(error.stderr, file=sys.stderr, end="")
        raise
