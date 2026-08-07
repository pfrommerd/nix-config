{
  cosmic-term,
  gnupatch,
  runCommandLocal,
}:

cosmic-term.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./pass-ctrl-shift-to-terminal.patch
    # Draw box-drawing characters as terminal cell primitives so pane
    # frames connect across rows instead of depending on font glyph bounds.
    ./terminal-box-drawing-overlay.patch
    # CSI 2031 light/dark change notifications (pop-os/cosmic-term#423):
    # emit `CSI ? 997 ; N n` when the profile theme switches. Pairs with
    # the vendored vte/alacritty_terminal patches below, which add mode
    # 2031 + the `CSI ? 996 n` query to the terminal backend.
    ./csi-2031-color-scheme-updates.patch
  ];
  # Patch vendored crates that cosmic-term depends on. Registry vendor dirs ship
  # an empty checksum `files` map, so editing them in place is safe.
  #
  # cosmic-text: its unix font fallback list misspells the Noto Sans Symbols 2
  # family, so text-presentation symbols like U+23FA (Claude Code's bullet) fall
  # through to the color emoji font instead of rendering monochrome.
  #
  # vte/alacritty_terminal: CSI 2031 support in the terminal backend
  # (pop-os/cosmic-term#423). vte gains private mode 2031 + the `CSI ? 996 n`
  # color-preference query; alacritty_terminal tracks the COLOR_SCHEME_UPDATES
  # mode and answers the query with `CSI ? 997 ; N n`.
  cargoDeps = runCommandLocal "cosmic-term-${old.version}-vendor-patched"
    { nativeBuildInputs = [ gnupatch ]; }
    ''
      cp -r --no-preserve=mode,ownership ${old.cargoDeps} $out
      patch -p1 -d $out/source-registry-0/cosmic-text-0.19.0 \
        < ${./cosmic-text-symbols2-family-name.patch}
      patch -p1 -d $out/source-registry-0/vte-0.15.0 \
        < ${./vte-csi-2031.patch}
      patch -p1 -d $out/source-registry-0/alacritty_terminal-0.25.1 \
        < ${./alacritty-terminal-csi-2031.patch}
    '';
})
