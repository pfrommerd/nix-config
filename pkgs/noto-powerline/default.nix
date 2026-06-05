{
  fetchurl,
  stdenvNoCC,
}:

let
  font = fetchurl {
    url = "https://raw.githubusercontent.com/powerline/fonts/master/NotoMono/Noto%20Mono%20for%20Powerline.ttf";
    name = "noto-mono-for-powerline.ttf";
    hash = "sha256-FQ1bMlSBXHIcFAwR2r8x8nn0T/zbNGLtXXgq1E5DvmA=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "noto-powerline";
  version = "unstable-2026-06-05";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${font} "$out/share/fonts/truetype/Noto Mono for Powerline.ttf"

    runHook postInstall
  '';
}
