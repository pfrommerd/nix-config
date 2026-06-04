{
  nixpkgs,
  ...
}: final: prev: {
  code-cursor = (final.callPackage ./pkgs/code-cursor {});
  cursor-cli = (final.callPackage ./pkgs/cursor-cli {});
  pi-agent-rust = (final.callPackage ./pkgs/pi-agent-rust {});
  # patched widevine for aarch64
  widevine-cdm = (final.callPackage ./pkgs/widevine-cdm {});
}
