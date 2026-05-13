{ config, lib, pkgs, ... }:
{
  imports = [ ../common.nix ../graphical.nix ../containers/paisa.nix ];
  options = {
    distro.machines.ececheira.enable = lib.mkEnableOption "ececheira configuration";
  };
  config = let cfg = config.distro.machines.ececheira;
      in lib.mkIf cfg.enable {

    distro.common.enable = true;
    distro.graphical.enable = true;
  };
}

