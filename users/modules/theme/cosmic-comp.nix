{lib, config, util, cosmicLib, inputs, ...}: let
  colors = util.colors;
  cfg = config.distro.theme;
  inherit (cosmicLib.cosmic) mkRON;

  trunc = f: if f < 0 then builtins.ceil f else builtins.floor f;
  pow = b: n: builtins.foldl' builtins.mul 1 (builtins.genList (_: b) n);
  truncateFloat = f: p: (trunc (f * pow 10 p)) / (pow 10.0 p);
  mkColor = c: let rgb = colors.hex.to.srgb c; in {
    red = truncateFloat rgb.r 5;
    green = truncateFloat rgb.g 5;
    blue = truncateFloat rgb.b 5;
  };
  mkColorOpaque = c: let rgb = colors.hex.to.srgb c; in {
    red = truncateFloat rgb.r 5;
    green = truncateFloat rgb.g 5;
    blue = truncateFloat rgb.b 5;
    alpha = 1.0;
  };
  mkColorAlpha = c: a: let rgb = colors.hex.to.srgb c; in {
    red = truncateFloat rgb.r 5;
    green = truncateFloat rgb.g 5;
    blue = truncateFloat rgb.b 5;
    alpha = a;
  };
  mkTheme = theme: {
    active_hint = lib.mkOverride 999 1;
    palette = mkRON "enum" {
      variant = if theme.dark then "Dark" else "Light";
      value = [{
        name = theme.name;
        blue = mkColorOpaque theme.palette.blue;
        red = mkColorOpaque theme.palette.red;
        green = mkColorOpaque theme.palette.green;
        yellow = mkColorOpaque theme.palette.yellow;

        gray_1 = mkColorOpaque theme.palette.mantle;
        gray_2 = mkColorOpaque theme.palette.crust;
        gray_3 = mkColorOpaque theme.palette.base;

        neutral_0 = mkColorOpaque theme.palette.crust;
        neutral_1 = mkColorOpaque theme.palette.mantle;
        neutral_2 = mkColorOpaque theme.palette.base;
        neutral_3 = mkColorOpaque theme.palette.surface0;
        neutral_4 = mkColorOpaque theme.palette.surface1;
        neutral_5 = mkColorOpaque theme.palette.surface2;
        neutral_6 = mkColorOpaque theme.palette.overlay0;
        neutral_7 = mkColorOpaque theme.palette.overlay1;
        neutral_8 = mkColorOpaque theme.palette.overlay2;
        neutral_9 = mkColorOpaque theme.palette.subtext0;
        neutral_10 = mkColorOpaque theme.palette.subtext1;

        bright_green = mkColorOpaque theme.palette.green;
        bright_red = mkColorOpaque theme.palette.red;
        bright_orange = mkColorOpaque theme.palette.peach;

        ext_warm_grey = mkColorOpaque theme.palette.overlay2;
        ext_orange = mkColorOpaque theme.palette.peach;
        ext_yellow = mkColorOpaque theme.palette.yellow;
        ext_blue = mkColorOpaque theme.palette.blue;
        ext_purple = mkColorOpaque theme.palette.lavender;
        ext_pink = mkColorOpaque theme.palette.pink;
        ext_indigo = mkColorOpaque theme.palette.mauve;

        accent_blue = mkColorOpaque theme.palette.blue;
        accent_red = mkColorOpaque theme.palette.red;
        accent_green = mkColorOpaque theme.palette.green;
        accent_warm_grey = mkColorOpaque theme.palette.overlay2;
        accent_orange = mkColorOpaque theme.palette.peach;
        accent_yellow = mkColorOpaque theme.palette.yellow;
        accent_purple = mkColorOpaque theme.palette.lavender;
        accent_pink = mkColorOpaque theme.palette.pink;
        accent_indigo = mkColorOpaque theme.palette.mauve;
      }];
    };
    bg_color = mkRON "optional" (
      mkColorAlpha theme.palette.base cfg.defaultOpacity
    );
    text_tint = mkRON "optional" (mkColor theme.palette.text);
    accent = mkRON "optional" (mkColor theme.palette.${theme.accent});
    success = mkRON "optional" (mkColor theme.palette.green);
    warning = mkRON "optional" (mkColor theme.palette.yellow);
    destructive = mkRON "optional" (mkColor theme.palette.red);
    neutral_tint = if theme.dark then
      mkRON "optional" (mkColor theme.palette.overlay1)
    else null;
    primary_container_bg = if theme.dark then
      mkRON "optional" (mkColorAlpha theme.palette.base cfg.defaultOpacity)
    else null;
    secondary_container_bg = if theme.dark then
      mkRON "optional" (mkColorAlpha theme.palette.surface0 cfg.defaultOpacity)
    else null;
  };
in {
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
  ];

  config = lib.mkIf (cfg.enable && config.wayland.desktopManager.cosmic.enable) {
    gtk.enable = true;
    wayland.desktopManager.cosmic.appearance = {
      theme.dark = mkTheme cfg.dark;
      theme.light = mkTheme cfg.light;
      theme.mode = if cfg.preferDark then "dark" else "light";
      toolkit.apply_theme_global = true;
    };
  };
}
