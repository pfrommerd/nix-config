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
    # DejaVu Sans Mono for Powerline is the configured terminal font on both
    # platforms (see theme/cosmic-term.nix and theme/ghostty.nix). Installed
    # everywhere so the family always resolves; on macOS home-manager links it
    # into ~/Library/Fonts where ghostty's CoreText lookup finds it.
    #
    # noto-fonts provides Noto Sans Symbols 2, which covers monochrome
    # text-presentation symbols DejaVu lacks (notably U+23FA ⏺, Claude's
    # message/tool bullet). On Linux cosmic-text's fallback list is patched to
    # spell that family correctly (see pkgs/cosmic-term), so the bullet renders
    # monochrome instead of as a filled color block.
    #
    # freefont_ttf provides FreeMono, cosmic-text's Braille fallback, so spinner
    # glyphs stay monospaced.
    home.packages = with pkgs; [ powerline-fonts noto-fonts freefont_ttf ] ++ (if pkgs.stdenv.isLinux then [
      brightnessctl playerctl libinput-gestures
      pulseaudio pavucontrol
      eog chromium code-cursor
      signal-desktop caprine zed-alias
    ] else []) ++ (if pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 then [
      discord spotify slack
    ] else []) ++ lib.optionals (config.restricted && pkgs.stdenv.isLinux) [
      # A `restricted` config is home-manager-only, so there is no NixOS module
      # (modules/graphical.nix -> services.desktopManager.cosmic) to provide the
      # COSMIC session. Ship the DE stack in the user environment instead so
      # `cosmic-session` can be launched from a home-manager-only login. Mirrors
      # nixpkgs' services.desktopManager.cosmic corePkgs plus the useful
      # apps/portals (greeter/initial-setup omitted — those need a display manager).
      cosmic-session cosmic-comp cosmic-panel cosmic-settings cosmic-settings-daemon
      cosmic-applets cosmic-app-library cosmic-bg cosmic-files cosmic-idle
      cosmic-launcher cosmic-notifications cosmic-osd cosmic-workspaces-epoch xwayland
      cosmic-edit cosmic-icons cosmic-randr cosmic-screenshot cosmic-term cosmic-wallpapers
      pop-launcher xdg-desktop-portal-cosmic xdg-desktop-portal-gtk
    ];

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
      userKeymaps = [
        # jkl; navigation (hjkl shifted one key right), matching the Helix setup.
        {
          context = "VimControl && !menu";
          bindings = {
            "j" = "vim::Left";
            "k" = "vim::Down";
            "l" = "vim::Up";
            ";" = "vim::Right";
          };
        }
      ];
    };
    # Terminal: cosmic-term on Linux (enabled by the COSMIC desktop, see
    # desktop.nix), ghostty on macOS. cosmic-term is Linux-only upstream and
    # the macOS port needed a pile of carried patches, so darwin uses ghostty
    # instead. Colors/opacity/decorations/font family come from the theme module
    # (see theme/ghostty.nix); the rest is set here.
    programs.ghostty = {
      enable = isDarwin;
      # pkgs.ghostty is Linux-only (meta.platforms), so darwin needs the
      # prebuilt universal Ghostty.app from upstream's releases.
      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        # Ghostty is launched by LaunchServices, which uses the macOS account
        # shell (zsh) rather than fish. --login so nix-darwin's /etc/fish
        # preinit runs and PATH picks up /run/current-system/sw/bin.
        command = "${lib.getExe pkgs.fish} --login";
        # ghostty's own terminfo (xterm-ghostty) isn't installed on the hosts
        # this ssh's into, so advertise the universally available entry.
        term = "xterm-256color";
        # Block cursor. cursor-style alone isn't enough: shell integration
        # forces a bar at the prompt regardless of it, so turn that feature off
        # (the rest of the shell integration stays on).
        cursor-style = "block";
        shell-integration-features = "no-cursor";
        window-padding-x = 4;
        window-padding-y = 6;
        font-size = 15;
      };
    };
  };
}
