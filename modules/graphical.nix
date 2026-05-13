{ config, pkgs, lib, inputs, ...}: {

    # If we have the "graphical" flavor
    options.distro.graphical.enable = lib.mkEnableOption "graphical presets";


    config = let cfg = config.distro.graphical;
        in lib.mkIf cfg.enable {
      # plymouth boot splash
      boot = {
        plymouth = let
          plymouth-theme = pkgs.stdenvNoCC.mkDerivation {
            pname = "plymouth-theme";
            version = "0.1.0";
            src = pkgs.fetchFromGitHub {
              owner = "SergioRibera";
              repo = "s4rchiso-plymouth-theme";
              rev = "2f782f4b68ce1c00cef3fde6970d7b4241bb97d4";
              sha256 = "sha256-bjtQvzupAFX5AYAIyBXSFgWhaG4nP4TvgKDoKyUhZ4U=";
            };
            buildInputs = [pkgs.nixos-icons];
            installPhase = ''
              mkdir -p $out/share/plymouth/themes/mac-style
              cp -r src/mac-style $out/share/plymouth/themes/
              cp ${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png $out/share/plymouth/themes/mac-style/images/header-image.png
              chmod +x $out/share/plymouth/themes/mac-style/mac-style.plymouth
              substituteInPlace $out/share/plymouth/themes/mac-style/mac-style.plymouth --replace '@IMAGES@' "$out/share/plymouth/themes/mac-style/images/"
            '';
          };
        in {
          enable = false;
          theme = "mac-style";
          themePackages = [plymouth-theme];
        };
        # Enable "Silent boot"
        #consoleLogLevel = 3;
        #initrd.verbose = false;
        #kernelParams = [
        #  "quiet"
        #  "udev.log_level=3"
        #  "systemd.show_status=auto"
        #];
        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        # loader.timeout = 0;
      };

      services.xserver.enable = true;
      services.libinput.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };


      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;

      # gnome keyring on login + seahorse GUI
      security.pam.services.cosmic-greeter.enableGnomeKeyring = true;
      services.gnome.gnome-keyring.enable = true;
      services.gnome.gcr-ssh-agent.enable = true;
      programs.seahorse.enable = true;

      services.geoclue2.enable = true;

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
}
