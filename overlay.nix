{
  nixpkgs,
  ...
}: final: prev: {
  code-cursor = (final.callPackage ./pkgs/code-cursor {});
  cursor-cli = (final.callPackage ./pkgs/cursor-cli {});
  noto-powerline = (final.callPackage ./pkgs/noto-powerline {});
  pi-coding-agent = (final.callPackage ./pkgs/pi-coding-agent {});
  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm {});
}
