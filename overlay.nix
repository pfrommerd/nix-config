{
  nixpkgs,
  ...
}:
final: prev: {
  code-cursor = (final.callPackage ./pkgs/code-cursor { });
  cursor-cli = (final.callPackage ./pkgs/cursor-cli { });
  pi-coding-agent = (final.callPackage ./pkgs/pi-coding-agent { });
  zed-editor = (final.callPackage ./pkgs/zed-editor { });
  cosmic-term = prev.cosmic-term.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./pkgs/cosmic-term/pass-ctrl-shift-to-terminal.patch
      ./pkgs/cosmic-term/fractional-wheel-scrolling.patch
    ];
  });
  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm { });
}
