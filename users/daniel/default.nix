{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  home = import ./home.nix;
in
{
  options.distro.users.daniel = {
    enable = lib.mkEnableOption "Daniel's user";

    sudo = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Make daniel a super-user";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = "/home/daniel";
    };

    graphical = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the graphical environment";
    };

    cosmic = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the COSMIC environment configuration";
    };
  };

  config =
    let
      cfg = config.distro.users.daniel;
    in
    lib.mkIf cfg.enable {

      age.secrets.daniel-passwd.file = ../../secrets/daniel-passwd.age;
      users.users.daniel = {
        isNormalUser = true;
        name = "daniel";
        home = cfg.home;
        shell = pkgs.fish;
        extraGroups = [
          "video"
          "networkmanager"
        ]
        ++ lib.optionals cfg.sudo [
          "wheel"
          "docker"
        ];
        hashedPasswordFile = config.age.secrets.daniel-passwd.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjasIJq1MDgp06wRwV1rfx+flR5BYwGZv2QumH2hyjA dan.pfrommer@gmail.com"
        ];
      };
      nix.settings.trusted-users = lib.optionals cfg.sudo [ "daniel" ];
      # Enable home-manager for daniel
      home-manager.users.daniel =
        { ... }:
        {
          imports = [
            inputs.agenix.homeManagerModules.default
            home
            {
              config.graphical = cfg.graphical;
              config.cosmic = cfg.cosmic;
            }
          ];
        };
    };
}
