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
      rev = "d9fb0cf4ba2ac6a7c607f7b3a81f13d4c172e7a7";
      hash = "sha256-GlyGpEHgFYtPvc5MYTYrvuGM+pSoQgw9CrKQelMGMP8=";
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
