{ config, pkgs, lib, inputs, ... }:
let
  zed-alias = (pkgs.writeShellScriptBin "zed" ''
    exec ${pkgs.zed-editor}/bin/zeditor "$@"
  '');
in {
  imports = [
    ../../modules/widevine.nix
    ./desktop.nix
  ];

  options.graphical = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable graphical home environment";
  };

  options.cosmic = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable cosmic desktop options";
  };

  config = lib.mkIf config.graphical {
    home.packages = with pkgs; (if pkgs.stdenv.isLinux then [
      brightnessctl playerctl libinput-gestures
      pulseaudio pavucontrol
      eog chromium code-cursor
      signal-desktop caprine zed-alias
    ] else []) ++ (if pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 then [
      discord spotify slack
    ] else []);

    programs.widevine.enable = pkgs.stdenv.isLinux;
    programs.firefox.enable = true;

    programs.zed-editor = {
      enable = true;
      userSettings = {
        vim_mode = true;
        auto_update = false;
        buffer_font_size = 14;
        buffer_font_features = { calt = false; };
      };
    };
    programs.alacritty = {
      enable = !pkgs.stdenv.isLinux;
      settings = {
        env = { TERM = "xterm-256color"; };
        window = {
          decorations = if pkgs.stdenv.isDarwin then "Buttonless"
          else "Full";
          opacity = if pkgs.stdenv.isDarwin then 1.0 else 0.9;
          padding = if pkgs.stdenv.isDarwin then { x = 4; y = 6; } else {};
        };
        font.size = if pkgs.stdenv.isDarwin then 15 else 12;
      };
    };
  };
}
