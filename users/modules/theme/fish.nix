{ config, pkgs, lib, ... }:
let palette = config.distro.theme.dark.palette;
    cfg = config.distro.theme;
in lib.mkIf (cfg.enable && config.programs.fish.enable) {
    xdg.configFile."fish/conf.d/theme.fish".source = pkgs.writeText "theme.fish" ''
    set fish_color_normal normal
    set fish_color_command blue
    set fish_color_param --dim yellow
    set fish_color_keyword magenta
    set fish_color_quote green
    set fish_color_redirection brmagenta
    set fish_color_end bryellow
    set fish_color_comment black
    set fish_color_error red
    set fish_color_gray brblack
    set fish_color_selection --background black
    set fish_color_search_match --background black
    set fish_color_option green
    set fish_color_operator brmagenta
    set fish_color_escape brred
    set fish_color_autosuggestion --dim black
    set fish_color_cancel red
    set fish_color_cwd yellow
    set fish_color_user cyan
    set fish_color_host blue
    set fish_color_host_remote magenta
    set fish_color_status red
    set fish_pager_color_progress --dim black
    set fish_pager_color_prefix brmagenta
    set fish_pager_color_completion normal
    set fish_pager_color_description --dim black
    '';
}
