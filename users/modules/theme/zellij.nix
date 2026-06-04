{ config, lib, ... }:
let
  cfg = config.distro.theme;

  # Matches upstream catppuccin/zellij naming.
  themeName = preset: "catppuccin-${preset}";

  mkThemeKdl = name: theme:
    let
      p = theme.palette;
      accent = p.${theme.accent};
      style = name: {
        base,
        background,
        emphasis_0 ? p.peach,
        emphasis_1 ? p.sky,
        emphasis_2 ? p.green,
        emphasis_3 ? p.mauve,
      }: ''
          ${name} {
            base "${base}"
            background "${background}"
            emphasis_0 "${emphasis_0}"
            emphasis_1 "${emphasis_1}"
            emphasis_2 "${emphasis_2}"
            emphasis_3 "${emphasis_3}"
          }
      '';
    in ''
      themes {
        ${name} {
      ${style "text_unselected" {
        base = p.text;
        background = p.crust;
      }}
      ${style "text_selected" {
        base = accent;
        background = p.surface0;
      }}
      ${style "ribbon_unselected" {
        base = p.subtext0;
        background = p.surface0;
        emphasis_0 = p.red;
        emphasis_1 = p.text;
        emphasis_2 = p.blue;
        emphasis_3 = p.mauve;
      }}
      ${style "ribbon_selected" {
        base = p.crust;
        background = accent;
        emphasis_0 = p.red;
        emphasis_1 = p.peach;
        emphasis_2 = p.mauve;
        emphasis_3 = p.blue;
      }}
      ${style "table_title" {
        base = accent;
        background = p.mantle;
      }}
      ${style "table_cell_unselected" {
        base = p.text;
        background = p.crust;
      }}
      ${style "table_cell_selected" {
        base = accent;
        background = p.surface0;
      }}
      ${style "list_unselected" {
        base = p.text;
        background = p.crust;
      }}
      ${style "list_selected" {
        base = accent;
        background = p.surface0;
      }}
      ${style "frame_unselected" {
        base = p.overlay0;
        background = p.crust;
      }}
      ${style "frame_selected" {
        base = accent;
        background = p.crust;
        emphasis_0 = p.peach;
        emphasis_1 = p.sky;
        emphasis_2 = accent;
        emphasis_3 = p.mauve;
      }}
      ${style "frame_highlight" {
        base = accent;
        background = p.crust;
        emphasis_0 = p.mauve;
        emphasis_1 = p.pink;
        emphasis_2 = accent;
        emphasis_3 = accent;
      }}
      ${style "exit_code_success" {
        base = p.green;
        background = p.crust;
      }}
      ${style "exit_code_error" {
        base = p.red;
        background = p.crust;
        emphasis_0 = p.yellow;
        emphasis_1 = p.peach;
        emphasis_2 = p.overlay2;
        emphasis_3 = p.mauve;
      }}
          multiplayer_user_colors {
            player_1 "${p.mauve}"
            player_2 "${p.blue}"
            player_3 "${p.lavender}"
            player_4 "${p.yellow}"
            player_5 "${p.sky}"
            player_6 "${p.peach}"
            player_7 "${p.red}"
            player_8 "${p.overlay2}"
            player_9 "${p.pink}"
            player_10 "${p.maroon}"
          }
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
