{
  lib,
  callPackage,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
  runCommand,
}:

rustPlatform.buildRustPackage (
  finalAttrs:
  let
    grammars = callPackage ./grammars.nix {
      source = finalAttrs.src;
    };
    runtime = runCommand "evil-helix-runtime" { } ''
      cp -r --no-preserve=mode,ownership ${finalAttrs.src}/runtime $out
      rm -rf $out/grammars
      ln -s ${grammars} $out/grammars
    '';
  in
  {
    pname = "evil-helix";
    version = "unstable-20260725";

    src = fetchFromGitHub {
      owner = "pfrommerd";
      repo = "evil-helix";
      rev = "e83edaf536fd3c7b095f5dbc1a52b25dd5a5111f";
      hash = "sha256-hX7QIb/CYEb472sDLMlC556LrxD2aLX/NyNcKBTxSjs=";
    };

    cargoHash = "sha256-wNcntxShQgaqZWafrZ5roRQqTmhQobUdcvuW/o+mBXQ=";

    nativeBuildInputs = [ installShellFiles ];

    env = {
      HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
      HELIX_DEFAULT_RUNTIME = runtime;
    };

    postInstall = ''
      installShellCompletion contrib/completion/hx.{bash,fish,zsh}
      mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
      cp contrib/Helix.desktop $out/share/applications
      cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
    '';

    passthru = {
      inherit grammars runtime;
    };

    meta = {
      description = "Post-modern modal text editor, with vim keybindings";
      homepage = "https://github.com/pfrommerd/evil-helix";
      license = lib.licenses.mpl20;
      mainProgram = "hx";
    };
  }
)
