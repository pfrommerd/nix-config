{ config, pkgs, lib, ... }:
let palette = config.distro.theme.dark.palette;
    cfg = config.distro.theme;
    themeFile = pkgs.writeText "theme.yml" ''
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

[colors.selection]
text = "${palette.base}"
background = "${palette.rosewater}"

[colors.normal]
black = "${palette.surface1}"
red = "${palette.red}"
green = "${palette.green}"
yellow = "${palette.yellow}"
blue = "${palette.blue}"
magenta = "${palette.mauve}"
cyan = "${palette.teal}"
white = "${palette.subtext1}"

[colors.bright]
black = "${palette.surface2}"
red = "${palette.red}"
green = "${palette.green}"
yellow = "${palette.yellow}"
blue = "${palette.blue}"
magenta = "${palette.pink}"
cyan = "${palette.teal}"
white = "${palette.subtext0}"

[[colors.indexed_colors]]
index = 16
color = "${palette.peach}"

[[colors.indexed_colors]]
index = 17
color = "${palette.rosewater}"
'';
   themePackage = pkgs.stdenvNoCC.mkDerivation {
    name = "alacritty-theme";
    src = themeFile;
    phases = [ "installPhase" ];
    installPhase = ''
        mkdir -p $out/share/alacritty-theme
        cp $src $out/share/alacritty-theme/theme.toml
    '';
   };
in lib.mkIf (cfg.enable && config.programs.alacritty.enable) {
    programs.alacritty.themePackage = themePackage;
    programs.alacritty.theme = "theme";
}
