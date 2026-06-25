{ config, pkgs, lib, inputs, framework, ... }:
let
  isDarwin = framework == "nix-darwin";
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
    # DejaVu Sans Mono is the cosmic-term font (see theme/cosmic-term.nix).
    # Installed on every platform so the configured font always resolves; on
    # macOS home-manager links it into ~/Library/Fonts where cosmic-term's
    # fontdb can find it.
    home.packages = with pkgs; [ dejavu_fonts ] ++ (if pkgs.stdenv.isLinux then [
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
    # Terminal: cosmic-term everywhere (alacritty retired).
    # On Linux it's enabled by the COSMIC desktop (see desktop.nix). On macOS
    # there is no COSMIC desktop, so we enable cosmic-manager's declarative
    # layer directly — this is lightweight (just lib.cosmic + the cosmic-term
    # config applied via cosmic-ext-ctl at activation) and gives us the same
    # themed terminal without pulling in the rest of COSMIC.
    wayland.desktopManager.cosmic.enable = lib.mkIf isDarwin true;
    programs.cosmic-term.enable = lib.mkIf isDarwin true;

    # cosmic-manager applies config via `cosmic-ctl`, which resolves paths with
    # etcetera's XDG base strategy: it defaults to ~/.config and only honours
    # $XDG_CONFIG_HOME. On macOS the COSMIC apps themselves read their config
    # from ~/Library/Application Support/cosmic, so without this the generated
    # files land in ~/.config/cosmic where nothing reads them. Point cosmic-ctl
    # at the macOS location for the cosmic activation steps. This export persists
    # into the subsequent activation entries (home-manager runs them in one
    # shell), so resetCosmic/configureCosmic both see it.
    home.activation.cosmicMacosConfigHome = lib.mkIf isDarwin (
      config.lib.dag.entryBefore
        ([ "configureCosmic" ]
          ++ lib.optional config.wayland.desktopManager.cosmic.resetFiles "resetCosmic")
        ''export XDG_CONFIG_HOME="$HOME/Library/Application Support"''
    );
  };
}
