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
  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm { });
}
