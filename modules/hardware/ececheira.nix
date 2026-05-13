{ config, lib, pkgs, modulesPath, ... }:

{
  options.distro.hardware.ececheira.enable = lib.mkEnableOption "ececheira hardware support";

  config = let cfg = config.distro.hardware.ececheira;
      in lib.mkIf cfg.enable {
    networking.hostName = "ececheira";
    networking.interfaces.enp4s0.useDHCP = true;

    time.timeZone = "America/New_York";

    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.graphics.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/a63850a3-93be-4e7b-88fd-203ee4389969";
      fsType = "btrfs";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/9E5A-4B55";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    swapDevices = [ ];
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
