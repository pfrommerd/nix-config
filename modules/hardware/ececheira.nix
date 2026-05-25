{ config, lib, pkgs, modulesPath, ... }:

{
  options.distro.hardware.ececheira.enable = lib.mkEnableOption "ececheira hardware support";

  config = let cfg = config.distro.hardware.ececheira;
      in lib.mkIf cfg.enable {
    time.timeZone = "America/New_York";

    networking.hostName = "ececheira";
    networking.interfaces.enp4s0.useDHCP = true;

    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
    hardware.bluetooth.enable = true;
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
    services.xserver.videoDrivers = [ "modesetting" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.kernelParams = [ "i915.enable_guc=3" ];
    boot.extraModulePackages = [ ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/a63850a3-93be-4e7b-88fd-203ee4389969";
      fsType = "btrfs";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/1F4C-D076";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    swapDevices = [ ];
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
