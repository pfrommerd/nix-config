{ config, lib, ... }:
{
  options.distro.hardware.athena.enable = lib.mkEnableOption "athena hardware";

  config = let cfg = config.distro.hardware.athena;
      in lib.mkIf cfg.enable {
    nix.enable = true;
    security.pam.services.sudo_local.touchIdAuth = true;
    system.stateVersion = 5;
  };
}
