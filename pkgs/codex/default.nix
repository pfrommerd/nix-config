{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  ripgrep,
  bubblewrap,
}:

let
  inherit (stdenvNoCC) hostPlatform;
  sourcesJson = lib.importJSON ./sources.json;
  sources = lib.mapAttrs (
    _: info:
    fetchurl {
      inherit (info) url hash;
    }
  ) sourcesJson.sources;
in
stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit (sourcesJson) version;

  src = sources.${hostPlatform.system};

  # Each archive holds a single, target-triple-suffixed `codex` binary.
  # Linux builds are static musl, so no autoPatchelf is needed.
  sourceRoot = ".";

  # Prebuilt release binary; stripping would invalidate the Darwin signature.
  dontStrip = true;

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 codex-* $out/bin/codex

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/codex \
      --prefix PATH : ${
        lib.makeBinPath (
          [ ripgrep ] ++ lib.optionals hostPlatform.isLinux [ bubblewrap ]
        )
      }
  '';

  passthru = {
    inherit sources;
  };

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames sources;
    mainProgram = "codex";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
