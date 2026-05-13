{ config, lib, pkgs, ... }:
{
  imports = [ ../common.nix ../graphical.nix ]; 
  options = {
    distro.machines.asahi.enable = lib.mkEnableOption "asahi configuration";
  };
  config = let cfg = config.distro.machines.asahi;
      in lib.mkIf cfg.enable {

    distro = {
      common.enable = true;
      graphical.enable = true;
    };

    services.openssh.enable = false; # disable ssh for laptop!
  };
}
