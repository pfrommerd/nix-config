{ config, lib, pkgs, inputs, modulesPath, ... }:

let firmware = pkgs.fetchurl {
  url = "https://github.com/pfrommerd/nix-config-public/releases/download/macos-firmware-v2/firmware.cpio";
  hash = "sha256-6HjH0aQiVSjTTrX4puroSf0CJlxVAfjD2NpQWVK8SyA=";
};
peripherals = pkgs.runCommand "asahi-peripherals" {} ''
  mkdir $out
  cp ${firmware} $out/firmware.cpio
'';
in
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
    ../common.nix
  ];
  options.distro.hardware.asahi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable asahi hardware support";
    };
  };
  config = let cfg = config.distro.hardware.asahi;
      in lib.mkIf cfg.enable {

    networking.hostName = "asahi";
    networking.networkmanager.enable = true;

    hardware.asahi.enable = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.kernelParams = ["appledrm.show_notch=1"];

    hardware.asahi.peripheralFirmwareDirectory = peripherals;
    environment.systemPackages = [ pkgs.libimobiledevice pkgs.asahi-bless pkgs.asahi-btsync ];

    distro.ci = {
      hardware = {
        inherit (pkgs) m1n1 uboot-asahi asahi-fwextract 
            alsa-ucm-conf-asahi asahi-audio;
	    kernel = config.boot.kernelPackages.kernel;
      };
    };

    services.libinput = {
      enable = true;
      touchpad.tapping = false;
      touchpad.naturalScrolling = true;
    };

    # Basic boot configuration

    boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = { 
      device = "/dev/disk/by-uuid/3ec02638-09b9-4318-bc45-ccba6a8126df";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/872D-13FD";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # DON'T CHANGE THIS
    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
