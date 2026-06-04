{ config, lib, ... }:
let
  cfg = config.distro.theme;

  # Matches upstream catppuccin/zellij naming and palette mapping.
  themeName = preset: "catppuccin-${preset}";

  mkThemeKdl = name: theme:
    let p = theme.palette;
    in ''
      themes {
        ${name} {
          bg "${p.surface2}"
          fg "${p.text}"
          red "${p.red}"
          green "${p.green}"
          blue "${p.blue}"
          yellow "${p.yellow}"
          magenta "${p.pink}"
          orange "${p.peach}"
          cyan "${p.sky}"
          black "${p.mantle}"
          white "${p.text}"
        }
      }
    '';

  darkTheme = themeName cfg.dark.preset;
  lightTheme = themeName cfg.light.preset;
  activeTheme =
    if cfg.preferDark then darkTheme else lightTheme;
in {
  config = lib.mkIf (cfg.enable && config.programs.zellij.enable) {
    programs.zellij = {
      themes = {
        ${darkTheme} = mkThemeKdl darkTheme cfg.dark;
      }
      // lib.optionalAttrs (darkTheme != lightTheme) {
        ${lightTheme} = mkThemeKdl lightTheme cfg.light;
      };
      settings.theme = activeTheme;
    };
  };
}
