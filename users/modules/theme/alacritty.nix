{ config, lib, pkgs, ... }:
let
  cfg = config.distro.theme;

  themeName = theme: "distro-${lib.strings.toLower theme.name}";

  # Render one alacritty color config from a distro palette. The ANSI blocks come
  # from `palette.ansi` (built by presets/default.nix), so alacritty and
  # cosmic-term agree on what the terminal emits for each ANSI color.
  mkThemeToml = theme:
    let
      palette = theme.palette;
      ansi = palette.ansi;
      ansiBlock = section: variant: ''
        [colors.${section}]
        black = "${ansi.black.${variant}}"
        red = "${ansi.red.${variant}}"
        green = "${ansi.green.${variant}}"
        yellow = "${ansi.yellow.${variant}}"
        blue = "${ansi.blue.${variant}}"
        magenta = "${ansi.magenta.${variant}}"
        cyan = "${ansi.cyan.${variant}}"
        white = "${ansi.white.${variant}}"
      '';
    in ''
      [colors.primary]
      background = "${palette.base}"
      foreground = "${palette.text}"
      dim_foreground = "${palette.overlay1}"
      bright_foreground = "${palette.text}"

      [colors.cursor]
      text = "${palette.base}"
      cursor = "${palette.rosewater}"

      [colors.vi_mode_cursor]
      text = "${palette.base}"
      cursor = "${palette.lavender}"

      [colors.selection]
      text = "${palette.base}"
      background = "${palette.rosewater}"

      [colors.search.matches]
      foreground = "${palette.base}"
      background = "${palette.subtext0}"

      [colors.search.focused_match]
      foreground = "${palette.base}"
      background = "${palette.green}"

      [colors.footer_bar]
      foreground = "${palette.base}"
      background = "${palette.subtext0}"

      [colors.hints.start]
      foreground = "${palette.base}"
      background = "${palette.yellow}"

      [colors.hints.end]
      foreground = "${palette.base}"
      background = "${palette.subtext0}"

      ${ansiBlock "normal" "normal"}
      ${ansiBlock "bright" "bright"}
      ${ansiBlock "dim" "dim"}
    '';

  # Both themes are installed; `programs.alacritty.theme` below picks the active
  # one. Alacritty has no system-appearance following, so dark/light switches
  # with distro.theme.preferDark (see the home-manager specialisations).
  themePackage = pkgs.stdenvNoCC.mkDerivation {
    name = "alacritty-distro-theme";
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/alacritty-theme
      cp ${pkgs.writeText "dark.toml" (mkThemeToml cfg.dark)} \
        $out/share/alacritty-theme/${themeName cfg.dark}.toml
      cp ${pkgs.writeText "light.toml" (mkThemeToml cfg.light)} \
        $out/share/alacritty-theme/${themeName cfg.light}.toml
      runHook postInstall
    '';
  };

  activeTheme = if cfg.preferDark then cfg.dark else cfg.light;
in {
  config = lib.mkIf (cfg.enable && config.programs.alacritty.enable) {
    programs.alacritty = {
      inherit themePackage;
      theme = themeName activeTheme;
      settings = {
        window = {
          opacity = cfg.terminal.opacity;
          # "Buttonless" is macOS-only: it keeps the rounded window but drops the
          # title bar and traffic lights, matching cosmic-term's hidden headerbar.
          decorations =
            if !cfg.terminal.borderless then "Full"
            else if pkgs.stdenv.isDarwin then "Buttonless"
            else "None";
        };
        # Same font as cosmic-term (see theme/cosmic-term.nix) — the powerline
        # patched DejaVu, so powerline glyphs render.
        font.normal.family = "DejaVu Sans Mono for Powerline";
      };
    };
  };
}
