{
  nixpkgs,
  ...
}:
final: prev: {
  evil-helix = (final.callPackage ./pkgs/evil-helix { });
  claude-code = (final.callPackage ./pkgs/claude-code { });
  code-cursor = (final.callPackage ./pkgs/code-cursor { });
  codex = (final.callPackage ./pkgs/codex { });
  cursor-cli = (final.callPackage ./pkgs/cursor-cli { });
  opencode = (final.callPackage ./pkgs/opencode { });
  zed-editor = (final.callPackage ./pkgs/zed-editor { });
  cosmic-term = final.callPackage ./pkgs/cosmic-term {
    cosmic-term = prev.cosmic-term;
  };
  # cosmic-ext-ctl applies cosmic-manager's declarative config at activation.
  # It's a pure CLI and builds cleanly on macOS; only its meta marks it Linux.
  cosmic-ext-ctl =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.cosmic-ext-ctl.overrideAttrs (o: {
        meta = o.meta // {
          platforms = o.meta.platforms ++ [ "aarch64-darwin" ];
        };
      })
    else prev.cosmic-ext-ctl;

  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm { });
}
