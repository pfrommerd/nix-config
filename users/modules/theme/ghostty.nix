{ config, lib, pkgs, ... }:
let
  cfg = config.distro.theme;

  themeName = theme: "distro-${lib.strings.toLower theme.name}";

  # Ghostty's 16 color palette entries, in ANSI order. The colors come from
  # `palette.ansi` (built by presets/default.nix), so ghostty and cosmic-term
  # agree on what the terminal emits for each ANSI color. Ghostty has no dim
  # block (unlike alacritty/cosmic-term), so `ansi.*.dim` goes unused.
  ansiOrder = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];

  mkTheme = theme:
    let
      palette = theme.palette;
      ansi = palette.ansi;
      entry = index: name: variant: "${toString index}=${ansi.${name}.${variant}}";
    in {
      palette =
        lib.imap0 (i: name: entry i name "normal") ansiOrder
        ++ lib.imap0 (i: name: entry (i + 8) name "bright") ansiOrder;
      background = palette.base;
      foreground = palette.text;
      cursor-color = palette.rosewater;
      cursor-text = palette.base;
      selection-background = palette.rosewater;
      selection-foreground = palette.base;
    };

  # Both themes are installed. Ghostty can follow the system appearance itself
  # (`theme = "dark:X,light:Y"`), but the rest of the config (helix, zellij,
  # jankyborders) keys off distro.theme.preferDark via the home-manager
  # specialisations, so pick the active theme the same way to keep them in sync.
  activeTheme = if cfg.preferDark then cfg.dark else cfg.light;
in {
  config = lib.mkIf (cfg.enable && config.programs.ghostty.enable) {
    programs.ghostty = {
      themes = {
        ${themeName cfg.dark} = mkTheme cfg.dark;
        ${themeName cfg.light} = mkTheme cfg.light;
      };
      settings = {
        theme = themeName activeTheme;
        background-opacity = cfg.terminal.opacity;
        # Same font as cosmic-term (see theme/cosmic-term.nix) — the powerline
        # patched DejaVu, so powerline glyphs render.
        font-family = "DejaVu Sans Mono for Powerline";
      }
      # Borderless is spelled differently per platform: on macOS "hidden" drops
      # the titlebar and traffic lights but keeps the rounded window and its
      # shadow (window-decoration = none would drop those too); elsewhere it is
      # the GTK-side window-decoration. Either way it matches cosmic-term's
      # hidden headerbar.
      // (if pkgs.stdenv.isDarwin then {
        macos-titlebar-style = if cfg.terminal.borderless then "hidden" else "native";
      } else {
        window-decoration = if cfg.terminal.borderless then "none" else "auto";
      });
    };
  };
}
