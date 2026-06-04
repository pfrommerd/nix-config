{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkgconfig ? null
, openssl ? null
, zlib ? null
, fd ? null
, ripgrep ? null
}:

let
  pname = "pi-agent-rust";
  # The version here is informational only; the fetchFromGitHub rev controls what is built.
  version = "0.1.0";
in

rustPlatform.buildRustPackage rec {
  inherit pname version;

  # Source: default to the repository's main branch. For reproducible builds,
  # set `rev` to a particular tag/commit and update `sha256`.
  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "pi_agent_rust";
    rev = "main";
    sha256 = "sha256-Sjl2uuCZUwGAuk2P3T9Pv3DK/M+kemfdtPvTUh+4OPU=";
  };
  cargoHash = "sha256-szG38cmbkuq8EIuZTNqypibk1LqhegszLFon4Y2LMSU=";

  # Minimal native build inputs required for many Rust builds; expose pkgconfig
  # as an optional dependency above so the overlay can decide.
  nativeBuildInputs = lib.optional (pkgconfig != null) pkgconfig;

  doCheck = false;

  # Common system libraries that may be required by TLS/HTTP backends.
  buildInputs = lib.filter (x: x != null) [
    openssl
    zlib
    fd
    ripgrep
  ];
}
