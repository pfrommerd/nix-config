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
      transparent = "#00000000";
      paneBg = color: setAlpha color opacity;
      paneBgDeep = color: setAlpha color opacity;
      paneBgDeeper = color: setAlpha color (opacity * 0.9);
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
        "background" = transparent;
        "background.appearance" = "blurred";
        "vim.mode.text" = palette.crust;
        "vim.normal.background" = paneBgDeeper palette.teal;
        "vim.helix_normal.background" = paneBgDeeper palette.rosewater;
        "vim.visual.background" = paneBgDeeper palette.lavender;
        "vim.helix_select.background" = paneBgDeeper palette.lavender;
        "vim.insert.background" = paneBgDeeper palette.green;
        "vim.visual_line.background" = paneBgDeeper palette.lavender;
        "vim.visual_block.background" = paneBgDeeper palette.mauve;
        "vim.replace.background" = paneBgDeeper palette.maroon;
        "border" = palette.surface0;
        "border.variant" = blend palette.surface0 accent 0.3;
        "border.focused" = palette.lavender;
        "border.selected" = blend palette.surface0 accent 0.4;
        "border.transparent" = palette.green;
        "border.disabled" = palette.overlay0;
        "elevated_surface.background" = paneBgDeeper palette.mantle;
        "surface.background" = paneBgDeep palette.mantle;
        "element.background" = paneBg palette.crust;
        "element.hover" = (setAlpha palette.surface0 0.4);
        "element.active" = (setAlpha palette.surface2 0.6);
        "element.selected" =
          if theme.dark then
            (setAlpha (lighten palette.surface0 0.1) 0.4)
          else
            (setAlpha (darken palette.surface0 0.1) 0.4);
        "element.disabled" = palette.overlay0;
        "drop_target.background" = (setAlpha palette.surface0 0.4);
        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = (setAlpha palette.surface1 0.3);
        "ghost_element.active" = (setAlpha palette.surface2 0.6);
        "ghost_element.selected" =
          if theme.dark then (setAlpha palette.surface2 0.4) else (setAlpha palette.surface2 0.4);
        "ghost_element.disabled" = palette.overlay0;
        "text" = palette.text;
        "text.muted" = palette.subtext1;
        "text.placeholder" = palette.surface2;
        "text.disabled" = palette.surface1;
        "text.accent" = accent;
        "icon" = palette.text;
        "icon.muted" = palette.overlay1;
        "icon.disabled" = palette.overlay0;
        "icon.placeholder" = palette.surface2;
        "icon.accent" = accent;
        "status_bar.background" = paneBg palette.crust;
        "title_bar.inactive_background" = paneBg palette.crust;
        "title_bar.background" = paneBg palette.mantle;
        "toolbar.background" = paneBg palette.mantle;
        "tab_bar.background" = paneBg palette.mantle;
        "tab.inactive_background" = paneBgDeep (darken palette.mantle 0.02);
        "tab.active_background" = paneBg palette.base;
        "search.match_background" = (setAlpha palette.teal 0.6);
        "panel.background" = (setAlpha palette.mantle 0.9);
        "panel.focused_border" = (setAlpha accent 0.7);
        "panel.indent_guide" = (setAlpha palette.surface0 0.3);
        "panel.indent_guide_active" = palette.surface2;
        "panel.indent_guide_hover" = accent;
        "panel.overlay_background" = paneBg palette.crust;
        "pane.focused_border" = (setAlpha accent 0.7);
        "pane_group.border" = palette.surface0;
        "scrollbar.thumb.background" = (setAlpha palette.surface2 0.8);
        "scrollbar.thumb.active_background" = null;
        "scrollbar.thumb.border" = null;
        "scrollbar.track.background" =
          if theme.dark then paneBgDeeper palette.crust else (setAlpha palette.crust 0.5);
        "scrollbar.track.border" = (setAlpha palette.text 0.07);
        "minimap.thumb.background" = (setAlpha palette.surface2 0.2);
        "minimap.thumb.hover_background" = (setAlpha accent 0.4);
        "minimap.thumb.active_background" = (setAlpha accent 0.6);
        "minimap.thumb.border" = null;
        "editor.foreground" = palette.text;
        "editor.background" = paneBgDeep palette.base;
        "editor.gutter.background" = paneBg (darken palette.base 0.01);
        "editor.subheader.background" = paneBg palette.mantle;
        "editor.active_line.background" = (setAlpha palette.text 0.07);
        "editor.highlighted_line.background" = null;
        "editor.line_number" = palette.overlay1;
        "editor.active_line_number" = accent;
        "editor.invisible" = (setAlpha palette.overlay2 0.4);
        "editor.wrap_guide" = palette.surface2;
        "editor.active_wrap_guide" = palette.surface2;
        "editor.document_highlight.bracket_background" = (setAlpha accent 0.09);
        "editor.document_highlight.read_background" = (setAlpha palette.subtext0 0.16);
        "editor.document_highlight.write_background" = (setAlpha palette.subtext0 0.16);
        "editor.indent_guide" = (setAlpha palette.surface0 0.4);
        "editor.indent_guide_active" = palette.surface2;

        # Terminal colors (concrete from palette and palette.ansi)
        "terminal.background" = if theme.dark then paneBgDeeper palette.base else palette.base;
        "terminal.ansi.background" = if theme.dark then paneBgDeeper palette.base else palette.base;
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

        # Miscellaneous UI color mappings (concrete)
        "link_text.hover" = palette.sky;
        "conflict" = palette.peach;
        "conflict.border" = palette.peach;
        "conflict.background" = setAlpha palette.peach 0.15;
        "created" = palette.green;
        "created.border" = palette.green;
        "created.background" = setAlpha palette.green 0.15;
        "deleted" = palette.red;
        "deleted.border" = palette.red;
        "deleted.background" = setAlpha palette.red 0.15;
        "hidden" = palette.overlay0;
        "hidden.border" = palette.overlay0;
        "hidden.background" = paneBg palette.mantle;
        "hint" = palette.surface2;
        "hint.border" = palette.surface2;
        "hint.background" = paneBg palette.mantle;
        "ignored" = palette.overlay0;
        "ignored.border" = palette.overlay0;
        "ignored.background" = setAlpha palette.overlay0 0.15;
        "modified" = palette.yellow;
        "modified.border" = palette.yellow;
        "modified.background" = setAlpha palette.yellow 0.15;
        "predictive" = palette.overlay0;
        "predictive.border" = palette.lavender;
        "predictive.background" = if theme.dark then paneBg palette.mantle else setAlpha palette.mantle 0.9;
        "renamed" = palette.sapphire;
        "renamed.border" = palette.sapphire;
        "renamed.background" = setAlpha palette.sapphire 0.5;
        "info" = palette.teal;
        "info.border" = palette.teal;
        "info.background" = setAlpha palette.overlay2 0.5;
        "warning" = palette.yellow;
        "warning.border" = palette.yellow;
        "warning.background" = setAlpha palette.yellow 0.5;
        "error" = palette.red;
        "error.border" = palette.red;
        "error.background" = setAlpha palette.red 0.5;
        "success" = palette.green;
        "success.border" = palette.green;
        "success.background" = setAlpha palette.green 0.5;
        "unreachable" = palette.red;
        "unreachable.border" = palette.red;
        "unreachable.background" = setAlpha palette.red 0.5;

        "version_control.added" = palette.green;
        "version_control.deleted" = palette.red;
        "version_control.modified" = palette.yellow;
        "version_control.renamed" = palette.sapphire;
        "version_control.conflict" = palette.peach;
        "version_control.conflict_marker.ours" = (setAlpha palette.green 0.2);
        "version_control.conflict_marker.theirs" = (setAlpha palette.blue 0.2);
        "version_control.ignored" = palette.overlay0;
        "debugger.accent" = palette.red;
        "editor.debugger_active_line.background" = (setAlpha palette.peach 0.07);

        # syntax highlighting colors
        syntax = {
          # Identifiers
          "variable" = {
            color = palette.text;
            font_style = null;
            font_weight = null;
          };
          "variable.builtin" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };
          "variable.parameter" = {
            color = palette.maroon;
            font_style = null;
            font_weight = null;
          };
          "variable.member" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "variable.special" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };

          "constant" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "constant.builtin" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "constant.macro" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };

          "module" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "label" = {
            color = palette.sapphire;
            font_style = null;
            font_weight = null;
          };

          # Literals
          "string" = {
            color = palette.green;
            font_style = null;
            font_weight = null;
          };
          "string.documentation" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };
          "string.regexp" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "string.escape" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "string.special" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "string.special.path" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "string.special.symbol" = {
            color = palette.flamingo;
            font_style = null;
            font_weight = null;
          };
          "string.special.url" = {
            color = palette.rosewater;
            font_style = null;
            font_weight = null;
          };

          "character" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };
          "character.special" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "boolean" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "number" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "number.float" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };

          # Types
          "type" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "type.builtin" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "type.definition" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "type.interface" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "type.super" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };

          "attribute" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "property" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };

          # Functions
          "function" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "function.builtin" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "function.call" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "function.macro" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };
          "function.method" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "function.method.call" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };

          "constructor" = {
            color = palette.flamingo;
            font_style = null;
            font_weight = null;
          };
          "operator" = {
            color = palette.sky;
            font_style = null;
            font_weight = null;
          };

          # Keywords
          "keyword" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.modifier" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.type" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.coroutine" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.function" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.operator" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.import" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.repeat" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.return" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.debug" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.exception" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.conditional.ternary" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "keyword.directive" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "keyword.directive.define" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "keyword.export" = {
            color = palette.sky;
            font_style = null;
            font_weight = null;
          };

          # Punctuation
          "punctuation" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "punctuation.delimiter" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "punctuation.bracket" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "punctuation.special" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "punctuation.special.symbol" = {
            color = palette.flamingo;
            font_style = null;
            font_weight = null;
          };
          "punctuation.list_marker" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };

          # Comment
          "comment" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "comment.doc" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "comment.documentation" = {
            color = palette.overlay2;
            font_style = null;
            font_weight = null;
          };
          "comment.error" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };
          "comment.warning" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "comment.hint" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "comment.todo" = {
            color = palette.flamingo;
            font_style = null;
            font_weight = null;
          };
          "comment.note" = {
            color = palette.rosewater;
            font_style = null;
            font_weight = null;
          };

          # Diff
          "diff.plus" = {
            color = palette.green;
            font_style = null;
            font_weight = null;
          };
          "diff.minus" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };

          # Tags
          "tag" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "tag.attribute" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "tag.delimiter" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };

          # Misc / Legacy
          "parameter" = {
            color = palette.maroon;
            font_style = null;
            font_weight = null;
          };
          "field" = {
            color = palette.lavender;
            font_style = null;
            font_weight = null;
          };
          "namespace" = {
            color = palette.yellow;
            font_style = null;
            font_weight = null;
          };
          "float" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "symbol" = {
            color = palette.pink;
            font_style = null;
            font_weight = null;
          };
          "string.regex" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "text" = {
            color = palette.text;
            font_style = null;
            font_weight = null;
          };

          "emphasis.strong" = {
            color = palette.maroon;
            font_style = null;
            font_weight = 700;
          };
          "emphasis" = {
            color = palette.maroon;
            font_style = null;
            font_weight = null;
          };
          "embedded" = {
            color = palette.maroon;
            font_style = null;
            font_weight = null;
          };
          "text.literal" = {
            color = palette.green;
            font_style = null;
            font_weight = null;
          };

          # Zed specific
          "concept" = {
            color = palette.sapphire;
            font_style = null;
            font_weight = null;
          };
          "enum" = {
            color = palette.teal;
            font_style = null;
            font_weight = 700;
          };
          "function.decorator" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "type.class.definition" = {
            color = palette.yellow;
            font_style = null;
            font_weight = 700;
          };

          "hint" = {
            color = palette.overlay1;
            font_style = null;
            font_weight = null;
          };
          "link_text" = {
            color = palette.lavender;
            font_style = null;
            font_weight = null;
          };
          "link_uri" = {
            color = palette.blue;
            font_style = null;
            font_weight = null;
          };
          "parent" = {
            color = palette.peach;
            font_style = null;
            font_weight = null;
          };
          "predictive" = {
            color = palette.overlay0;
            font_style = null;
            font_weight = null;
          };
          "predoc" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };
          "primary" = {
            color = palette.maroon;
            font_style = null;
            font_weight = null;
          };
          "tag.doctype" = {
            color = palette.mauve;
            font_style = null;
            font_weight = null;
          };
          "string.doc" = {
            color = palette.teal;
            font_style = null;
            font_weight = null;
          };
          "title" = {
            color = palette.text;
            font_style = null;
            font_weight = 800;
          };
          "variant" = {
            color = palette.red;
            font_style = null;
            font_weight = null;
          };
        };
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
