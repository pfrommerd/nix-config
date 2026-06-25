{
  nixpkgs,
  ...
}:
final: prev: {
  code-cursor = (final.callPackage ./pkgs/code-cursor { });
  cursor-cli = (final.callPackage ./pkgs/cursor-cli { });
  pi-coding-agent = (final.callPackage ./pkgs/pi-coding-agent { });
  zed-editor = (final.callPackage ./pkgs/zed-editor { });
  cosmic-term =
    let
      patched = prev.cosmic-term.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./pkgs/cosmic-term/pass-ctrl-shift-to-terminal.patch
          # cfg!(macos)-gated; no-op on Linux.
          ./pkgs/cosmic-term/no-daemon-on-macos.patch
        ];
      });
    in
    # cosmic-term is Linux-only upstream because the default feature set pulls
    # the wayland backend (-> cosmic-client-toolkit -> smithay-client-toolkit ->
    # libinput/libwayland). Building with just the winit/wgpu backend drops all
    # of that and compiles & runs natively on macOS.
    if prev.stdenv.hostPlatform.isDarwin then
      patched.overrideAttrs (o: {
        # NOTE: buildRustPackage already consumed buildFeatures/
        # buildNoDefaultFeatures into these cargo* attrs, so override THESE.
        cargoBuildNoDefaultFeatures = true;
        cargoBuildFeatures = [ "wgpu" ];
        cargoCheckNoDefaultFeatures = true;
        cargoCheckFeatures = [ "wgpu" ];
        doCheck = false;
        # libinput is only needed for the (now-disabled) wayland backend.
        buildInputs =
          builtins.filter (x: (x.pname or x.name or "") != "libinput") o.buildInputs;
        # libcosmic-app-hook wraps the binary with linux wayland/vulkan/xkb env.
        nativeBuildInputs = builtins.filter
          (x: !(prev.lib.hasInfix "libcosmic-app-hook" (x.name or "")))
          o.nativeBuildInputs;
        # pop-os/winit's macOS (appkit) backend panics at startup
        # ("view must be installed in a window") when iced queries the maximized
        # state. Patch the vendored crate in place — it's a git source with an
        # empty cargo checksum, so editing it doesn't break vendoring.
        cargoDeps = final.runCommandLocal "cosmic-term-1.0.16-vendor-patched"
          { nativeBuildInputs = [ final.gnupatch ]; }
          ''
            cp -r --no-preserve=mode,ownership ${o.cargoDeps} $out
            patch -p1 -d $out/source-git-9/winit-appkit-0.31.0-beta.2 \
              < ${./pkgs/cosmic-term/winit-appkit-macos-frame-guard.patch}
          '';
        meta = o.meta // {
          platforms = o.meta.platforms ++ [ "aarch64-darwin" ];
        };
      })
    else patched;
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
