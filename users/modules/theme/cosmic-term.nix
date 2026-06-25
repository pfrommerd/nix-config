{lib, config, ...}: let
  cfg = config.distro.theme;
  mkScheme = theme: let
      palette = theme.palette;
      ansi = theme.palette.ansi;
  in {
    name = theme.name;
    cursor = palette.rosewater;
    bright_foreground = palette.text;
    dim_foreground = palette.overlay1;
    foreground = palette.text;
    mode = if theme.dark then "dark" else "light";
    bright = {
      black = ansi.black.bright;
      blue = ansi.blue.bright;
      cyan = ansi.cyan.bright;
      green = ansi.green.bright;
      magenta = ansi.magenta.bright;
      red = ansi.red.bright;
      white = ansi.white.bright;
      yellow = ansi.yellow.bright;
    };
    dim = {
      black = ansi.black.dim;
      blue = ansi.blue.dim;
      cyan = ansi.cyan.dim;
      green = ansi.green.dim;
      magenta = ansi.magenta.dim;
      red = ansi.red.dim;
      white = ansi.white.dim;
      yellow = ansi.yellow.dim;
    };
    normal = {
      black = ansi.black.normal;
      blue = ansi.blue.normal;
      cyan = ansi.cyan.normal;
      green = ansi.green.normal;
      magenta = ansi.magenta.normal;
      red = ansi.red.normal;
      white = ansi.white.normal;
      yellow = ansi.yellow.normal;
    };
  };
in {
  config = lib.mkIf (cfg.enable && config.programs.cosmic-term.enable) {
    programs.cosmic-term = {
      profiles = [
        {
          command = null;
          hold = false;
          is_default = true;
          name = "Default";
          syntax_theme_dark = cfg.dark.name;
          syntax_theme_light = cfg.light.name;
        }
      ];
      colorSchemes = [
        (mkScheme cfg.dark)
        (mkScheme cfg.light)
      ];
      settings = {
        # Follow the system appearance so the dark/light syntax themes above
        # switch automatically (macOS appearance, or the COSMIC theme on Linux).
        app_theme = {
          __type = "enum";
          variant = "System";
        };
        opacity = builtins.floor (cfg.terminal.opacity * 100);
        show_headerbar = !cfg.terminal.borderless;
      };
    };
  };
}
