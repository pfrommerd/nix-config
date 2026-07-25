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
  cosmic-term =
    let
      patched = prev.cosmic-term.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./pkgs/cosmic-term/pass-ctrl-shift-to-terminal.patch
          # cfg!(macos)-gated; no-op on Linux.
          ./pkgs/cosmic-term/no-daemon-on-macos.patch
          # cfg!(macos)-gated; no-op on Linux.
          ./pkgs/cosmic-term/macos-follow-system-appearance.patch
          # Draw box-drawing characters as terminal cell primitives so pane
          # frames connect across rows instead of depending on font glyph bounds.
          ./pkgs/cosmic-term/terminal-box-drawing-overlay.patch
          # CSI 2031 light/dark change notifications (pop-os/cosmic-term#423):
          # emit `CSI ? 997 ; N n` when the profile theme switches. Pairs with
          # the vendored vte/alacritty_terminal patches below, which add mode
          # 2031 + the `CSI ? 996 n` query to the terminal backend.
          ./pkgs/cosmic-term/csi-2031-color-scheme-updates.patch
        ];
        # cosmic-text's macOS common fallback uses Apple UI/terminal fonts before
        # the Linux Noto/DejaVu terminal fallback chain, so terminal glyphs can
        # render differently from Linux (notably box drawing in zellij). It can
        # also reach Apple Color Emoji for text-presentation symbols like U+23FA
        # (Claude Code's bullet). Patch the vendored fallback lists so macOS
        # prefers the same Noto/DejaVu families as Linux, while also fixing the
        # Noto Sans Symbols 2 family spelling on Unix. Registry vendor dirs ship
        # an empty checksum `files` map, so editing in place is safe.
        cargoDeps = final.runCommandLocal "cosmic-term-1.0.16-vendor-cosmic-text-patched"
          { nativeBuildInputs = [ final.gnupatch ]; }
          ''
            cp -r --no-preserve=mode,ownership ${old.cargoDeps} $out
            patch -p1 -d $out/source-registry-0/cosmic-text-0.19.0 \
              < ${./pkgs/cosmic-term/cosmic-text-mono-symbol-fallback.patch}
            # CSI 2031 support in the terminal backend (pop-os/cosmic-term#423):
            # vte gains private mode 2031 + the `CSI ? 996 n` color-preference
            # query; alacritty_terminal tracks the COLOR_SCHEME_UPDATES mode and
            # answers the query with `CSI ? 997 ; N n`. Registry vendor dirs ship
            # an empty checksum `files` map, so editing in place is safe.
            patch -p1 -d $out/source-registry-0/vte-0.15.0 \
              < ${./pkgs/cosmic-term/vte-csi-2031.patch}
            patch -p1 -d $out/source-registry-0/alacritty_terminal-0.25.1 \
              < ${./pkgs/cosmic-term/alacritty-terminal-csi-2031.patch}
          '';
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
        # Layer the winit fix on top of the cosmic-text-patched cargoDeps from
        # `patched` (o.cargoDeps is already the runCommand output above).
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
