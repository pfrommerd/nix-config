let
    util = import ../../../../util;
    inherit (util.colors.hex) lighten;

    # Wrap a syntax color in Zed's { color, font_style, font_weight } shape.
    s = color: { inherit color; font_style = null; font_weight = null; };

    # `code` is the per-theme syntax styling map (palette.code.<token>). zed.nix
    # consumes it verbatim as its `syntax` block, so each theme family keeps its
    # own correct mapping of syntax tokens -> palette colors.
    #
    # codeBase is the Catppuccin mapping, shared by every Catppuccin flavor since
    # they only differ in hex values, not in which named color a token uses.
    codeBase = palette: {
      # Identifiers
      "variable" = s palette.text;
      "variable.builtin" = s palette.red;
      "variable.parameter" = s palette.maroon;
      "variable.member" = s palette.blue;
      "variable.special" = s palette.red;

      "constant" = s palette.peach;
      "constant.builtin" = s palette.peach;
      "constant.macro" = s palette.mauve;

      "module" = s palette.yellow;
      "label" = s palette.sapphire;

      # Literals
      "string" = s palette.green;
      "string.documentation" = s palette.teal;
      "string.regexp" = s palette.peach;
      "string.escape" = s palette.pink;
      "string.special" = s palette.pink;
      "string.special.path" = s palette.pink;
      "string.special.symbol" = s palette.flamingo;
      "string.special.url" = s palette.rosewater;

      "character" = s palette.teal;
      "character.special" = s palette.pink;
      "boolean" = s palette.peach;
      "number" = s palette.peach;
      "number.float" = s palette.peach;

      # Types
      "type" = s palette.yellow;
      "type.builtin" = s palette.mauve;
      "type.definition" = s palette.yellow;
      "type.interface" = s palette.yellow;
      "type.super" = s palette.yellow;

      "attribute" = s palette.peach;
      "property" = s palette.blue;

      # Functions
      "function" = s palette.blue;
      "function.builtin" = s palette.peach;
      "function.call" = s palette.blue;
      "function.macro" = s palette.teal;
      "function.method" = s palette.blue;
      "function.method.call" = s palette.blue;

      "constructor" = s palette.flamingo;
      "operator" = s palette.sky;

      # Keywords
      "keyword" = s palette.mauve;
      "keyword.modifier" = s palette.mauve;
      "keyword.type" = s palette.mauve;
      "keyword.coroutine" = s palette.mauve;
      "keyword.function" = s palette.mauve;
      "keyword.operator" = s palette.mauve;
      "keyword.import" = s palette.mauve;
      "keyword.repeat" = s palette.mauve;
      "keyword.return" = s palette.mauve;
      "keyword.debug" = s palette.mauve;
      "keyword.exception" = s palette.mauve;
      "keyword.conditional" = s palette.mauve;
      "keyword.conditional.ternary" = s palette.mauve;
      "keyword.directive" = s palette.pink;
      "keyword.directive.define" = s palette.pink;
      "keyword.export" = s palette.sky;

      # Punctuation
      "punctuation" = s palette.overlay2;
      "punctuation.delimiter" = s palette.overlay2;
      "punctuation.bracket" = s palette.overlay2;
      "punctuation.special" = s palette.pink;
      "punctuation.special.symbol" = s palette.flamingo;
      "punctuation.list_marker" = s palette.teal;

      # Comment
      "comment" = s palette.overlay2;
      "comment.doc" = s palette.overlay2;
      "comment.documentation" = s palette.overlay2;
      "comment.error" = s palette.red;
      "comment.warning" = s palette.yellow;
      "comment.hint" = s palette.blue;
      "comment.todo" = s palette.flamingo;
      "comment.note" = s palette.rosewater;

      # Diff
      "diff.plus" = s palette.green;
      "diff.minus" = s palette.red;

      # Tags
      "tag" = s palette.blue;
      "tag.attribute" = s palette.yellow;
      "tag.delimiter" = s palette.teal;

      # Preprocessor
      "preproc" = s palette.pink;

      # Misc / Legacy
      "parameter" = s palette.maroon;
      "field" = s palette.lavender;
      "namespace" = s palette.yellow;
      "float" = s palette.peach;
      "symbol" = s palette.pink;
      "string.regex" = s palette.peach;
      "text" = s palette.text;

      "emphasis.strong" = {
        color = palette.maroon;
        font_style = null;
        font_weight = 700;
      };
      "emphasis" = s palette.maroon;
      "embedded" = s palette.maroon;
      "text.literal" = s palette.green;

      # Zed specific
      "concept" = s palette.sapphire;
      "enum" = {
        color = palette.teal;
        font_style = null;
        font_weight = 700;
      };
      "function.decorator" = s palette.peach;
      "type.class.definition" = {
        color = palette.yellow;
        font_style = null;
        font_weight = 700;
      };

      "hint" = s palette.overlay1;
      "link_text" = s palette.lavender;
      "link_uri" = s palette.blue;
      "parent" = s palette.peach;
      "predictive" = s palette.overlay0;
      "predoc" = s palette.red;
      "primary" = s palette.maroon;
      "tag.doctype" = s palette.mauve;
      "string.doc" = s palette.teal;
      "title" = {
        color = palette.text;
        font_style = null;
        font_weight = 800;
      };
      "variant" = s palette.red;
    };

    # Fadetouched diverges from the Catppuccin role assignments on these tokens
    # (mirroring ports/zed/fadetouched.json). Everything else falls through to
    # codeBase, recolored by the Fadetouched palette.
    codeFadetouched = palette: codeBase palette // {
      "constant.builtin" = s palette.red;
      "constant.macro" = s palette.lavender;
      "string.regexp" = s palette.pink;
      "string.regex" = s palette.pink;
      "type.builtin" = s palette.yellow;
      "attribute" = s palette.yellow;
      "constructor" = s palette.yellow;
      "keyword.directive" = s palette.lavender;
      "keyword.directive.define" = s palette.lavender;
      "punctuation" = s palette.subtext0;
      "punctuation.delimiter" = s palette.subtext0;
      "punctuation.bracket" = s palette.subtext0;
      "comment" = {
        color = palette.overlay1;
        font_style = "italic";
        font_weight = null;
      };
      "tag" = s palette.teal;
      "preproc" = s palette.lavender;
      "emphasis" = {
        color = palette.blue;
        font_style = "italic";
        font_weight = null;
      };
      "emphasis.strong" = {
        color = palette.peach;
        font_style = null;
        font_weight = 700;
      };
      "embedded" = s palette.text;
      "function.decorator" = s palette.lavender;
      "link_text" = s palette.teal;
      "title" = {
        color = palette.yellow;
        font_style = null;
        font_weight = 700;
      };
    };

    # Attach a `code` map (built from the theme's own palette) under palette.code.
    withCode = codeFn: theme: theme // {
      palette = theme.palette // { code = codeFn theme.palette; };
    };

    mkAnsi = theme: let
    palette = theme.palette;
  in theme // {
    palette = theme.palette // {
      ansi = {
        black = {
          dim = palette.overlay0;
          normal = palette.surface1;
          bright = palette.surface2;
        };
        red = {
          dim = palette.red;
          normal = palette.red;
          bright = palette.maroon;
        };
        green = {
          dim = palette.green;
          normal = palette.green;
          bright = lighten palette.green 0.05;
        };
        yellow = {
          dim = palette.flamingo;
          normal = palette.yellow;
          bright = palette.peach;
        };
        blue = {
          dim = palette.blue;
          normal = palette.blue;
          bright = palette.sapphire;
        };
        magenta = {
          dim = palette.mauve;
          normal = palette.mauve;
          bright = palette.pink;
        };
        cyan = {
          dim = palette.teal;
          normal = palette.teal;
          bright = palette.sky;
        };
        white = {
          dim = palette.subtext0;
          normal = palette.subtext0;
          bright = palette.subtext1;
        };
      };
    };
  };
in
{
    latte = mkAnsi (withCode codeBase (import ./latte.nix));
    frappe = mkAnsi (withCode codeBase (import ./frappe.nix));
    macchiato = mkAnsi (withCode codeBase (import ./macchiato.nix));
    mocha = mkAnsi (withCode codeBase (import ./mocha.nix));
    fadetouched = mkAnsi (withCode codeFadetouched (import ./fadetouched.nix));
}
