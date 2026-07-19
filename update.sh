#!/usr/bin/env bash
# Run every package's update.py to refresh pinned sources.
set -euo pipefail

# Resolve the repo root: the script's own directory when run in-tree, or the
# current working directory when executed from the nix store (nix run .#update).
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$root/pkgs" ]; then
  root="$PWD"
fi
cd "$root"

if [ ! -d pkgs ]; then
  echo "error: no pkgs/ directory found (run from the nix-config root)" >&2
  exit 1
fi

status=0
for script in pkgs/*/update.py; do
  [ -e "$script" ] || continue
  echo "==> $script"
  if ! "$script"; then
    echo "!! $script failed" >&2
    status=1
  fi
done

exit "$status"
