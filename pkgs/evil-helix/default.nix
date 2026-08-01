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
    version = "unstable-20260731";

    src = fetchFromGitHub {
      owner = "pfrommerd";
      repo = "evil-helix";
      rev = "08f3a70d82709fb8516d3a507bb9218dc6a6ad01";
      hash = "sha256-qA5WSFCfyiCnGAAeXGIp/kfy9xPX74tULQN1S9m5Amo=";
    };

    cargoHash = "sha256-DuJleibTFUkmLOf8lzfCHVwD2cWZkOXv9nLP9Ek0I0I=";

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
