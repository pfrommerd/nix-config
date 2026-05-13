{ config, lib, pkgs, modulesPath, ... }:
{
  options.distro.hardware.kronos.enable = lib.mkEnableOption "kronos hardware support";

  config = let cfg = config.distro.hardware.kronos;
      in lib.mkIf cfg.enable {

    networking.hostName = "kronos";
    networking.interfaces.enp4s0.useDHCP = true;

    time.timeZone = "America/New_York";

    # Hardware configuration:
    hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    services.xserver.videoDrivers = ["nvidia"];
    services.displayManager.gdm.autoSuspend = lib.mkDefault false;

    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Add the drivers to nix-ld so unpatched cuda-libraries can find libcuda.so
    programs.nix-ld.libraries = [
	    config.boot.kernelPackages.nvidiaPackages.stable
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/7707dca9-00e3-4a4d-a469-a9514ee3bed4";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/1A8B-D2B8";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [{
      device = "/var/lib/swapfile";
      size = 16*1024;
    }];

    system.stateVersion = "24.05";
  };
}
