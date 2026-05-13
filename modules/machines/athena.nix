{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../../users/daniel/darwin
  ];
  options.distro.machines.athena.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable modules for athena setup";
  };
  config = let cfg = config.distro.machines.athena;
      in lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ attic-client ];

    users.users.daniel = {
       name = "daniel";
       home = "/Users/daniel";
    };
    home-manager.users.daniel = {...}: {
       imports = [
        inputs.agenix.homeManagerModules.default
         ../../users/daniel/home.nix
         { config.graphical = true; }
       ];
    };
  };
}
