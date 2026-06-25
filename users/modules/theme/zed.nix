{
  config,
  util,
  lib,
  ...
}:
let
  cfg = config.distro.theme;
  opacity = cfg.editor.opacity;
  inherit (util.colors.hex)
    blend
    lighten
    darken
    setAlpha
    ;
  mkTheme =
    theme:
    let
      palette = theme.palette;
      accent = palette.${theme.accent};
      rainbow = [
        (blend palette.red palette.text 0.35)
        (blend palette.peach palette.text 0.35)
        (blend palette.yellow palette.text 0.35)
        (blend palette.green palette.text 0.35)
        (blend palette.sapphire palette.text 0.35)
        (blend palette.lavender palette.text 0.35)
        (blend palette.mauve palette.text 0.35)
      ];
    in
    {
      name = theme.name;
      appearance = if theme.dark then "dark" else "light";
      style = {
        accents = map (color: setAlpha color 0.5) (lib.reverseList rainbow);
        players = [
          {
            cursor = palette.rosewater;
            selection =
              if theme.dark then (setAlpha palette.rosewater 0.25) else (setAlpha palette.rosewater 0.3);
            background = palette.rosewater;
          }
        ]
        ++ map (color: {
          cursor = color;
          selection = if theme.dark then (setAlpha color 0.25) else (setAlpha color 0.3);
          background = color;
        }) rainbow;

        # Window / surfaces (Fadetouched: background == mantle, surfaces step up the neutral ramp)
        "background" =
          if theme.dark then
            (setAlpha palette.mantle opacity)
          else
            (setAlpha (lighten palette.mantle 0.01) opacity);
        "background.appearance" = "blurred";

        # Vim mode indicators (no Fadetouched analogue; kept palette-driven)
        "vim.mode.text" = palette.crust;
        "vim.normal.background" = palette.teal;
        "vim.helix_normal.background" = palette.rosewater;
        "vim.visual.background" = palette.lavender;
        "vim.helix_select.background" = palette.lavender;
        "vim.insert.background" = palette.green;
        "vim.visual_line.background" = palette.lavender;
        "vim.visual_block.background" = palette.mauve;
        "vim.replace.background" = palette.maroon;

        # Borders (Fadetouched: border == surface2, variant == surface1, focused == indigo)
        "border" = palette.surface2;
        "border.variant" = palette.surface1;
        "border.focused" = palette.lavender;
        "border.selected" = setAlpha palette.lavender 0.6;
        "border.transparent" = "#00000000";
        "border.disabled" = palette.surface1;

        "elevated_surface.background" = palette.surface0;
        "surface.background" = (setAlpha palette.mantle opacity);
        "element.background" = palette.surface0;
        "element.hover" = palette.surface1;
        "element.active" = palette.surface2;
        "element.selected" = palette.surface2;
        "element.disabled" = palette.surface0;
        "drop_target.background" = (setAlpha palette.subtext0 0.25);
        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = (setAlpha palette.text 0.05);
        "ghost_element.active" = palette.surface2;
        "ghost_element.selected" = palette.surface2;
        "ghost_element.disabled" = palette.surface0;

        # Text (Fadetouched: muted == subtext0, placeholder/disabled == overlay1)
        "text" = palette.text;
        "text.muted" = palette.subtext0;
        "text.placeholder" = palette.overlay1;
        "text.disabled" = palette.overlay1;
        "text.accent" = accent;
        "icon" = palette.subtext0;
        "icon.muted" = palette.overlay1;
        "icon.disabled" = palette.overlay1;
        "icon.placeholder" = palette.subtext0;
        "icon.accent" = accent;

        # Bars (Fadetouched: title/status/tab bars == mantle, toolbar/active tab == base)
        "status_bar.background" = (setAlpha palette.mantle opacity);
        "title_bar.inactive_background" = (setAlpha palette.crust opacity);
        "title_bar.background" = (setAlpha palette.mantle opacity);
        "toolbar.background" = (setAlpha palette.base opacity);
        "tab_bar.background" = (setAlpha palette.mantle opacity);
        "tab.inactive_background" = (setAlpha palette.mantle opacity);
        "tab.active_background" = (setAlpha palette.base opacity);
        "search.match_background" = (setAlpha palette.teal 0.3);
        "search.active_match_background" = (setAlpha palette.peach 0.4);
        "panel.background" = (setAlpha palette.mantle opacity);
        "panel.focused_border" = (setAlpha accent 0.7);
        "panel.indent_guide" = (setAlpha palette.surface0 0.7);
        "panel.indent_guide_active" = palette.surface2;
        "panel.indent_guide_hover" = accent;
        "panel.overlay_background" = (setAlpha palette.crust opacity);
        "pane.focused_border" = (setAlpha accent 0.7);
        "pane_group.border" = palette.surface0;

        # Scrollbar (Fadetouched: thumb == overlay0, transparent track)
        "scrollbar.thumb.background" = (setAlpha palette.overlay0 0.5);
        "scrollbar.thumb.hover_background" = (setAlpha palette.overlay0 0.7);
        "scrollbar.thumb.active_background" = null;
        "scrollbar.thumb.border" = "#00000000";
        "scrollbar.track.background" = "#00000000";
        "scrollbar.track.border" = "#00000000";
        "minimap.thumb.background" = (setAlpha palette.surface2 0.2);
        "minimap.thumb.hover_background" = (setAlpha accent 0.4);
        "minimap.thumb.active_background" = (setAlpha accent 0.6);
        "minimap.thumb.border" = null;

        # Editor (Fadetouched: editor/gutter == base, guides/highlights tinted with text)
        "editor.foreground" = palette.text;
        "editor.background" = (setAlpha palette.base (opacity * opacity * opacity));
        "editor.gutter.background" = (setAlpha palette.base opacity);
        "editor.subheader.background" = (setAlpha palette.surface0 opacity);
        "editor.active_line.background" = (setAlpha palette.text 0.05);
        "editor.highlighted_line.background" = palette.surface0;
        "editor.line_number" = palette.overlay1;
        "editor.active_line_number" = accent;
        "editor.hover_line_number" = palette.subtext0;
        "editor.invisible" = palette.overlay1;
        "editor.wrap_guide" = (setAlpha palette.text 0.05);
        "editor.active_wrap_guide" = (setAlpha palette.text 0.1);
        "editor.document_highlight.bracket_background" = (setAlpha accent 0.09);
        "editor.document_highlight.read_background" = (setAlpha palette.teal 0.18);
        "editor.document_highlight.write_background" = (setAlpha palette.overlay0 0.4);
        "editor.indent_guide" = (setAlpha palette.text 0.08);
        "editor.indent_guide_active" = (setAlpha palette.text 0.22);

        # Terminal colors (concrete from palette and palette.ansi)
        "terminal.background" = palette.base;
        "terminal.ansi.background" = palette.base;
        "terminal.foreground" = palette.text;
        "terminal.dim_foreground" = palette.overlay1;
        "terminal.bright_foreground" = palette.text;

        # Normal ANSI colors (use palette primaries where appropriate)
        "terminal.ansi.black" = palette.ansi.black.normal;
        "terminal.ansi.white" = palette.ansi.white.normal;
        "terminal.ansi.red" = palette.ansi.red.normal;
        "terminal.ansi.green" = palette.ansi.green.normal;
        "terminal.ansi.yellow" = palette.ansi.yellow.normal;
        "terminal.ansi.blue" = palette.ansi.blue.normal;
        "terminal.ansi.magenta" = palette.ansi.magenta.normal;
        "terminal.ansi.cyan" = palette.ansi.cyan.normal;

        # Bright ANSI colors (from palette.ansi.bright)
        "terminal.ansi.bright_black" = palette.ansi.black.bright;
        "terminal.ansi.bright_white" = palette.ansi.white.bright;
        "terminal.ansi.bright_red" = palette.ansi.red.bright;
        "terminal.ansi.bright_green" = palette.ansi.green.bright;
        "terminal.ansi.bright_yellow" = palette.ansi.yellow.bright;
        "terminal.ansi.bright_blue" = palette.ansi.blue.bright;
        "terminal.ansi.bright_magenta" = palette.ansi.magenta.bright;
        "terminal.ansi.bright_cyan" = palette.ansi.cyan.bright;

        # Dim ANSI colors (from palette.ansi.normal, like alacritty)
        "terminal.ansi.dim_black" = palette.ansi.black.dim;
        "terminal.ansi.dim_white" = palette.ansi.white.dim;
        "terminal.ansi.dim_red" = palette.ansi.red.dim;
        "terminal.ansi.dim_green" = palette.ansi.green.dim;
        "terminal.ansi.dim_yellow" = palette.ansi.yellow.dim;
        "terminal.ansi.dim_blue" = palette.ansi.blue.dim;
        "terminal.ansi.dim_magenta" = palette.ansi.magenta.dim;
        "terminal.ansi.dim_cyan" = palette.ansi.cyan.dim;

        # Status / diagnostics (Fadetouched mapping)
        "link_text.hover" = palette.sky;
        "conflict" = palette.peach;
        "conflict.border" = setAlpha palette.peach 0.4;
        "conflict.background" = setAlpha palette.peach 0.12;
        "created" = palette.green;
        "created.border" = setAlpha palette.green 0.4;
        "created.background" = setAlpha palette.green 0.12;
        "deleted" = palette.red;
        "deleted.border" = setAlpha palette.red 0.4;
        "deleted.background" = setAlpha palette.red 0.12;
        "hidden" = palette.overlay1;
        "hidden.border" = setAlpha palette.overlay1 0.4;
        "hidden.background" = setAlpha palette.overlay1 0.12;
        "hint" = palette.sky;
        "hint.border" = setAlpha palette.sky 0.4;
        "hint.background" = setAlpha palette.sky 0.12;
        "ignored" = palette.overlay1;
        "ignored.border" = setAlpha palette.overlay1 0.4;
        "ignored.background" = setAlpha palette.overlay1 0.12;
        "modified" = palette.yellow;
        "modified.border" = setAlpha palette.yellow 0.4;
        "modified.background" = setAlpha palette.yellow 0.12;
        "predictive" = palette.overlay1;
        "predictive.border" = setAlpha palette.overlay1 0.4;
        "predictive.background" = setAlpha palette.overlay1 0.12;
        "renamed" = palette.teal;
        "renamed.border" = setAlpha palette.teal 0.4;
        "renamed.background" = setAlpha palette.teal 0.12;
        "info" = palette.teal;
        "info.border" = setAlpha palette.teal 0.65;
        "info.background" = setAlpha palette.teal 0.28;
        "warning" = palette.yellow;
        "warning.border" = setAlpha palette.yellow 0.65;
        "warning.background" = setAlpha palette.yellow 0.28;
        "error" = palette.red;
        "error.border" = setAlpha palette.red 0.65;
        "error.background" = setAlpha palette.red 0.28;
        "success" = palette.green;
        "success.border" = setAlpha palette.green 0.65;
        "success.background" = setAlpha palette.green 0.28;
        "unreachable" = palette.subtext0;
        "unreachable.border" = setAlpha palette.subtext0 0.4;
        "unreachable.background" = setAlpha palette.subtext0 0.12;

        "version_control.added" = palette.green;
        "version_control.deleted" = palette.red;
        "version_control.modified" = palette.yellow;
        "version_control.renamed" = palette.teal;
        "version_control.conflict" = palette.peach;
        "version_control.word_added" = (setAlpha palette.green 0.35);
        "version_control.word_deleted" = (setAlpha palette.red 0.35);
        "version_control.conflict_marker.ours" = (setAlpha palette.green 0.12);
        "version_control.conflict_marker.theirs" = (setAlpha palette.blue 0.12);
        "version_control.ignored" = palette.overlay0;
        "debugger.accent" = palette.red;
        "editor.debugger_active_line.background" = (setAlpha palette.peach 0.07);

        # syntax highlighting colors come from the per-theme palette.code map
        # (see users/modules/theme/presets/default.nix).
        syntax = palette.code;
      };
    };
in
{
  config = lib.mkIf (cfg.enable && config.programs.zed-editor.enable) {
    programs.zed-editor = {
      themes = {
        nix-system = {
          "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
          name = "Nix System Themes";
          author = "Flake Custom";
          themes = [
            (mkTheme cfg.dark)
            (mkTheme cfg.light)
          ];
        };
      };
      userSettings.theme = {
        mode = "system";
        light = cfg.light.name;
        dark = cfg.dark.name;
      };
    };
  };
}
