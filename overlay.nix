{
  nixpkgs,
  ...
}: final: prev: {
  code-cursor = (final.callPackage ./pkgs/code-cursor {});
  cursor-cli = (final.callPackage ./pkgs/cursor-cli {});
  pi-coding-agent = (final.callPackage ./pkgs/pi-coding-agent {});
  zed-editor = (final.callPackage ./pkgs/zed-editor {});
  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm {});
}
