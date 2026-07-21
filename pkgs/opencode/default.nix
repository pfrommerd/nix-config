{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  ripgrep,
  sysctl,
  zlib,
}:

let
  inherit (stdenv) hostPlatform;
  sourcesJson = lib.importJSON ./sources.json;
  sources = lib.mapAttrs (
    _: info:
    fetchurl {
      inherit (info) url hash;
    }
  ) sourcesJson.sources;
in
stdenv.mkDerivation {
  pname = "opencode";
  inherit (sourcesJson) version;

  src = sources.${hostPlatform.system};

  # Archives contain a single `opencode` binary at the root.
  sourceRoot = ".";

  # bun-compiled single-file executable; stripping breaks it.
  dontStrip = true;
  __noChroot = hostPlatform.isDarwin;

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals hostPlatform.isLinux [
    autoPatchelfHook
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 opencode $out/bin/opencode

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${
        lib.makeBinPath (
          [ ripgrep ] ++ lib.optionals hostPlatform.isDarwin [ sysctl ]
        )
      } \
      --set OPENCODE_DISABLE_AUTOUPDATE true
  '';

  passthru = {
    inherit sources;
  };

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    changelog = "https://github.com/anomalyco/opencode/releases";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "opencode";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
