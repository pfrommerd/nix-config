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
      rev = "f9e2b4dbab9930a3c4ebc471147da456be7bf214";
      hash = "sha256-v79dZ/jnjKzvoLT4lfJOxXR+I4aOsWs/uQeYRjkZP84=";
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
