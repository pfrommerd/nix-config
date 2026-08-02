#!/usr/bin/env python3
"""Fetch every tree-sitter grammar pinned by helix's languages.toml.

This runs inside a fixed-output derivation, which is the only place allowed to
touch the network. Doing the fetch here rather than in Nix keeps languages.toml
out of the evaluator: reading it at eval time was an import-from-derivation, so
`nix flake check` had to realise the helix source -- and could not do so at all
from a runner of a foreign system.

Usage: fetch-grammars.py <languages.toml> <output dir>

Output layout:
    repos/<repo>-<short rev>/   checkout with .git and non-build dirs stripped
    manifest.json               [{name, repo, subpath}] sorted by grammar name

Grammars sharing a git url and rev (tree-sitter-typescript ships both
typescript and tsx, for example) are fetched once and share a repo directory.
Everything written here feeds a fixed output hash, so it must be reproducible:
no timestamps, no clone-order dependence, no network state beyond the pinned
revs.
"""

import json
import os
import re
import shutil
import subprocess
import sys
import time
import tomllib
from concurrent.futures import ThreadPoolExecutor

# Not needed to compile parser.c/scanner.c, and they dominate the closure size.
# Pruning is deterministic, so it does not destabilise the output hash.
PRUNE = frozenset(
    [
        ".git",
        ".github",
        "bindings",
        "corpus",
        "docs",
        "examples",
        "node_modules",
        "test",
    ]
)


def use_grammar(config, grammar):
    """Mirror helix's own use-grammars filtering."""
    only = config.get("use-grammars", {}).get("only")
    if only is not None:
        return grammar["name"] in only
    except_ = config.get("use-grammars", {}).get("except")
    if except_ is not None:
        return grammar["name"] not in except_
    return True


def is_git_grammar(grammar):
    source = grammar.get("source")
    return isinstance(source, dict) and "git" in source and "rev" in source


def repo_dir_name(url, rev):
    base = re.sub(r"[^A-Za-z0-9._-]", "-", url.rstrip("/").rsplit("/", 1)[-1])
    base = re.sub(r"\.git$", "", base) or "grammar"
    return f"{base}-{rev[:12]}"


# `git fetch` otherwise forks a detached `gc --auto` that keeps writing into
# .git after fetch returns, racing the prune below into "Directory not empty".
NO_BACKGROUND_WORK = [
    "-c",
    "gc.auto=0",
    "-c",
    "maintenance.auto=false",
    "-c",
    "fetch.writeCommitGraph=false",
]


def git(*args, cwd=None):
    subprocess.run(
        ["git", *NO_BACKGROUND_WORK, *args],
        cwd=cwd,
        check=True,
        stdout=subprocess.DEVNULL,
    )


def prune(dest):
    for root, dirs, _ in os.walk(dest, topdown=True):
        for name in [d for d in dirs if d in PRUNE]:
            shutil.rmtree(os.path.join(root, name))
            dirs.remove(name)


def fetch(url, rev, dest):
    os.makedirs(dest, exist_ok=True)
    git("init", "-q", cwd=dest)
    git("remote", "add", "origin", url, cwd=dest)
    try:
        # Cheapest path: ask for the one commit we pin. Not every host allows
        # fetching an arbitrary sha, so fall back to the full history.
        git("fetch", "-q", "--depth", "1", "origin", rev, cwd=dest)
    except subprocess.CalledProcessError:
        git("fetch", "-q", "--tags", "origin", cwd=dest)
    git("checkout", "-q", "--detach", rev, cwd=dest)

    # Disabling auto-gc above should make the prune race-free, but a stray
    # writer here would corrupt the fixed output hash rather than fail loudly,
    # so retry before giving up.
    for attempt in range(3):
        try:
            prune(dest)
            return
        except OSError:
            if attempt == 2:
                raise
            time.sleep(1)


def main():
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <languages.toml> <output dir>")
    languages_toml, out = sys.argv[1], sys.argv[2]

    with open(languages_toml, "rb") as handle:
        config = tomllib.load(handle)

    grammars = [
        g
        for g in config.get("grammar", [])
        if is_git_grammar(g) and use_grammar(config, g)
    ]

    # Deduplicate by (url, rev) so shared repos are cloned once.
    repos = {}
    manifest = []
    for grammar in sorted(grammars, key=lambda g: g["name"]):
        source = grammar["source"]
        key = (source["git"], source["rev"])
        repos.setdefault(key, repo_dir_name(*key))
        manifest.append(
            {
                "name": grammar["name"],
                "repo": repos[key],
                "subpath": source.get("subpath", ""),
            }
        )

    os.makedirs(os.path.join(out, "repos"), exist_ok=True)
    # Network-bound, so oversubscribe the cores nix gave us.
    workers = min(16, (os.cpu_count() or 1) * 4)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        list(
            pool.map(
                lambda item: fetch(*item[0], os.path.join(out, "repos", item[1])),
                repos.items(),
            )
        )

    with open(os.path.join(out, "manifest.json"), "w") as handle:
        json.dump(manifest, handle, indent=2, sort_keys=True)
        handle.write("\n")


if __name__ == "__main__":
    main()
