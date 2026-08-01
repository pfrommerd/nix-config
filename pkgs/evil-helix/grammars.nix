{
  lib,
  cacert,
  git,
  jq,
  python3,
  stdenv,
  stdenvNoCC,
  source,
  # Hash of the fetched grammar sources. Changes whenever the pinned helix rev
  # changes languages.toml; refresh it alongside src/cargoHash in default.nix.
  grammarSourcesHash,
}:

let
  # Fixed-output derivation: the one place with network access, and the reason
  # nothing here needs to read languages.toml at evaluation time. See
  # fetch-grammars.py for the output layout.
  grammarSources = stdenvNoCC.mkDerivation {
    name = "evil-helix-grammar-sources";

    nativeBuildInputs = [
      cacert
      git
      python3
    ];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      python3 ${./fetch-grammars.py} ${source}/languages.toml $out
      runHook postBuild
    '';

    dontInstall = true;
    dontFixup = true;

    # git shells out to curl, which wants the bundle named explicitly here --
    # SSL_CERT_FILE alone is not enough.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    # Ignore any ambient user config so the checkouts stay reproducible.
    GIT_CONFIG_GLOBAL = "/dev/null";
    GIT_LFS_SKIP_SMUDGE = "1";
    GIT_TERMINAL_PROMPT = "0";

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = grammarSourcesHash;
  };
in
stdenv.mkDerivation {
  name = "evil-helix-grammars";

  src = grammarSources;

  nativeBuildInputs = [ jq ];

  dontUnpack = true;
  dontConfigure = true;
  dontInstall = true;

  libraryExtension = stdenv.hostPlatform.extensions.sharedLibrary;
  stripLibraries = if stdenv.hostPlatform.isLinux then "1" else "0";

  buildPhase = ''
    runHook preBuild
    source ${./build-grammars.sh}
    runHook postBuild
  '';
}
