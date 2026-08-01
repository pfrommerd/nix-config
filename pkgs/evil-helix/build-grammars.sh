# Compile every grammar listed in the fetched sources' manifest.json.
#
# Sourced as a buildPhase, so it inherits $src, $out, $CC, $CXX, $STRIP and
# $NIX_BUILD_CORES from stdenv. Reads $libraryExtension and $stripLibraries from
# grammars.nix.

build_grammar() {
  set -eu
  local name=$1 repo=$2 subpath=${3:-}
  local dir="$src/repos/$repo${subpath:+/$subpath}"
  local library="$name$libraryExtension"
  local work
  work=$(mktemp -d)
  trap 'rm -rf "$work"' RETURN

  # Same flags the old per-grammar derivation used.
  local flags=(-Isrc -g -O3 -fPIC -fno-exceptions)

  # scanner.c may include headers from outside its subpath (tree-sitter-typescript
  # reaches up into common/), so compile against the checkout in place rather
  # than copying the subpath out on its own.
  if [[ -e $dir/src/scanner.cc ]]; then
    (cd "$dir" && $CXX -c src/scanner.cc -o "$work/scanner.o" "${flags[@]}")
  elif [[ -e $dir/src/scanner.c ]]; then
    (cd "$dir" && $CC -c src/scanner.c -o "$work/scanner.o" "${flags[@]}")
  fi

  (cd "$dir" && $CC -c src/parser.c -o "$work/parser.o" "${flags[@]}")
  $CXX -shared -o "$work/$library" "$work"/*.o

  if [[ $stripLibraries == 1 ]]; then
    $STRIP "$work/$library"
  fi

  mv "$work/$library" "$out/$library"
}
export -f build_grammar
export src out libraryExtension stripLibraries

mkdir -p "$out"

# One field per line, then NUL-delimited so empty subpaths survive. Feeding
# xargs tab-separated lines is not safe here: most grammars have no subpath, and
# xargs treats the resulting trailing whitespace as a line continuation, which
# silently merges two grammars into one.
if ! jq -r '.[] | (.name, .repo, .subpath)' "$src/manifest.json" \
  | tr '\n' '\0' \
  | xargs -0 -r -P "$NIX_BUILD_CORES" -n 3 bash -c 'build_grammar "$@"' _; then
  echo "error: one or more grammars failed to build" >&2
  exit 1
fi

# xargs catches build failures, but a grammar skipped for any other reason would
# otherwise ship a partial runtime directory that only surfaces later as missing
# syntax highlighting.
expected=$(jq 'length' "$src/manifest.json")
actual=$(find "$out" -maxdepth 1 -name "*$libraryExtension" | wc -l)
if [[ $expected != "$actual" ]]; then
  echo "error: built $actual grammars, manifest lists $expected" >&2
  exit 1
fi
echo "built $actual grammars"
