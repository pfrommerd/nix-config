{
  config,
  lib,
  ...
}:
let
  cfg = config.distro.theme;

  # Build a Helix theme (TOML) from a distro palette. Scopes reference palette
  # entries by name; the concrete hex values are exposed in the `[palette]`
  # table at the bottom. The main editing surface (`ui.background`) is left
  # without a `bg`, so the terminal background shows through (transparent).
  mkTheme =
    theme:
    let
      palette = theme.palette;
      accent = theme.accent;
      # The palette also carries nested `ansi`/`code` attrsets; Helix's palette
      # table only accepts flat color values, so keep just the hex strings.
      paletteColors = lib.filterAttrs (_: v: builtins.isString v) palette;
      name = "distro-${lib.strings.toLower theme.name}";
    in
    {
      inherit name;
      theme = {
        # Syntax
        "attribute" = "yellow";
        "type" = "yellow";
        "type.builtin" = "yellow";
        "type.enum.variant" = "teal";
        "constructor" = "sapphire";

        "constant" = "peach";
        "constant.builtin" = "peach";
        "constant.builtin.boolean" = "peach";
        "constant.character" = "teal";
        "constant.character.escape" = "pink";
        "constant.numeric" = "peach";

        "string" = "green";
        "string.regexp" = "peach";
        "string.special" = "blue";
        "string.special.url" = "blue";
        "string.special.path" = "pink";
        "string.special.symbol" = "flamingo";

        "comment" = {
          fg = "overlay2";
          modifiers = [ "italic" ];
        };

        "variable" = "text";
        "variable.builtin" = "red";
        "variable.parameter" = {
          fg = "maroon";
          modifiers = [ "italic" ];
        };
        "variable.other.member" = "blue";

        "label" = "sapphire";
        "punctuation" = "overlay2";
        "punctuation.special" = "pink";
        "keyword" = "mauve";
        "keyword.control" = "mauve";
        "keyword.control.import" = "mauve";
        "keyword.directive" = "pink";
        "operator" = "sky";
        "function" = "blue";
        "function.builtin" = "peach";
        "function.method" = "blue";
        "function.macro" = "teal";
        "tag" = "blue";
        "namespace" = "yellow";
        "special" = "blue";

        # Markup
        "markup.heading.marker" = "peach";
        "markup.heading.1" = "red";
        "markup.heading.2" = "peach";
        "markup.heading.3" = "yellow";
        "markup.heading.4" = "green";
        "markup.heading.5" = "sapphire";
        "markup.heading.6" = "lavender";
        "markup.list" = "teal";
        "markup.bold" = {
          modifiers = [ "bold" ];
        };
        "markup.italic" = {
          modifiers = [ "italic" ];
        };
        "markup.strikethrough" = {
          modifiers = [ "crossed_out" ];
        };
        "markup.link.url" = {
          fg = "blue";
          modifiers = [ "underlined" ];
        };
        "markup.link.text" = "lavender";
        "markup.raw" = "green";
        "markup.quote" = "yellow";

        "diff.plus" = "green";
        "diff.minus" = "red";
        "diff.delta" = "blue";

        # UI — `ui.background` intentionally has no `bg` so the terminal shows
        # through and the editor background is transparent.
        "ui.background" = { };
        "ui.background.separator" = "overlay0";
        "ui.text" = "text";
        "ui.text.focus" = {
          fg = "text";
          bg = "surface0";
          modifiers = [ "bold" ];
        };
        "ui.text.inactive" = "overlay1";
        "ui.text.directory" = "blue";
        "ui.linenr" = "surface1";
        "ui.linenr.selected" = accent;
        "ui.cursorline.primary" = {
          bg = "surface0";
        };
        "ui.virtual" = "overlay0";
        "ui.virtual.ruler" = {
          bg = "surface0";
        };
        "ui.virtual.whitespace" = "surface1";
        "ui.virtual.indent-guide" = "surface0";
        "ui.virtual.inlay-hint" = {
          fg = "overlay0";
          modifiers = [ "italic" ];
        };
        "ui.virtual.jump-label" = {
          fg = "red";
          modifiers = [ "bold" ];
        };
        "ui.selection" = {
          bg = "surface1";
        };
        "ui.selection.primary" = {
          bg = "surface2";
        };
        "ui.cursor" = {
          fg = "base";
          bg = "rosewater";
        };
        "ui.cursor.primary" = {
          fg = "base";
          bg = "rosewater";
        };
        "ui.cursor.match" = {
          fg = "peach";
          modifiers = [ "bold" ];
        };
        "ui.cursor.primary.normal" = {
          fg = "base";
          bg = "rosewater";
        };
        "ui.cursor.primary.insert" = {
          fg = "base";
          bg = "green";
        };
        "ui.cursor.primary.select" = {
          fg = "base";
          bg = "lavender";
        };
        "ui.highlight" = {
          bg = "surface1";
        };
        # Popups/menus keep a solid surface for legibility over transparency.
        "ui.popup" = {
          fg = "text";
          bg = "surface0";
        };
        "ui.popup.info" = {
          fg = "text";
          bg = "surface0";
        };
        "ui.window" = "crust";
        "ui.help" = {
          fg = "overlay2";
          bg = "surface0";
        };
        "ui.menu" = {
          fg = "overlay2";
          bg = "surface0";
        };
        "ui.menu.selected" = {
          fg = "text";
          bg = "surface1";
          modifiers = [ "bold" ];
        };
        "ui.menu.scroll" = {
          fg = "lavender";
          bg = "surface1";
        };

        # Statusline — solid mantle bar; mode indicators mirror the cosmic/zed
        # vim-mode accents.
        "ui.statusline" = {
          fg = "subtext1";
          bg = "mantle";
        };
        "ui.statusline.inactive" = {
          fg = "surface2";
          bg = "mantle";
        };
        "ui.statusline.normal" = {
          fg = "base";
          bg = "lavender";
          modifiers = [ "bold" ];
        };
        "ui.statusline.insert" = {
          fg = "base";
          bg = "green";
          modifiers = [ "bold" ];
        };
        "ui.statusline.select" = {
          fg = "base";
          bg = "flamingo";
          modifiers = [ "bold" ];
        };
        "ui.bufferline" = {
          fg = "subtext1";
          bg = "mantle";
        };
        "ui.bufferline.active" = {
          fg = "text";
          bg = "base";
          modifiers = [ "bold" ];
        };

        # Diagnostics
        "error" = "red";
        "warning" = "yellow";
        "info" = "sky";
        "hint" = "teal";
        "diagnostic.error" = {
          underline = {
            color = "red";
            style = "curl";
          };
        };
        "diagnostic.warning" = {
          underline = {
            color = "yellow";
            style = "curl";
          };
        };
        "diagnostic.info" = {
          underline = {
            color = "sky";
            style = "curl";
          };
        };
        "diagnostic.hint" = {
          underline = {
            color = "teal";
            style = "curl";
          };
        };
        "diagnostic.unnecessary" = {
          modifiers = [ "dim" ];
        };

        palette = paletteColors;
      };
    };

  darkTheme = mkTheme cfg.dark;
  lightTheme = mkTheme cfg.light;
  activeTheme = if cfg.preferDark then darkTheme else lightTheme;
in
{
  config = lib.mkIf (cfg.enable && config.programs.helix.enable) {
    programs.helix = {
      themes = {
        ${darkTheme.name} = darkTheme.theme;
        ${lightTheme.name} = lightTheme.theme;
      };
      settings.theme = activeTheme.name;
    };
  };
}
