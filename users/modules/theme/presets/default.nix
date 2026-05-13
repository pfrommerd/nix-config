let
    util = import ../../../../util;
    inherit (util.colors.hex) lighten;
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
    latte = mkAnsi (import ./latte.nix);
    frappe = mkAnsi (import ./frappe.nix);
    macchiato = mkAnsi (import ./macchiato.nix);
    mocha = mkAnsi (import ./mocha.nix);
}
