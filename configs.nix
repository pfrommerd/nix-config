{
  athena = {
    system = "aarch64-darwin";

    imports = [
      ./modules/hardware/athena.nix
      ./modules/machines/athena.nix
    ];

    hardware.athena.enable = true;
    machines.athena.enable = true;
  };

  kronos = {
    system = "x86_64-linux";

    imports = [
      ./modules/hardware/kronos.nix
      ./modules/machines/kronos.nix
      ./users/daniel
    ];

    hardware.kronos.enable = true;
    machines.kronos.enable = true;

    users.daniel.enable = true;
    users.daniel.sudo = true;
  };

  ececheira = {
    system = "x86_64-linux";

    imports = [
      ./modules/hardware/ececheira.nix
      ./modules/machines/ececheira.nix
      ./users/daniel
    ];

    hardware.ececheira.enable = true;
    machines.ececheira.enable = true;

    users.daniel.enable = true;
    users.daniel.graphical = true;
    users.daniel.sudo = true;
  };

  asahi = {
    system = "aarch64-linux";

    imports = [
      ./modules/hardware/asahi.nix
      ./modules/machines/asahi.nix
      ./users/daniel
    ];

    hardware.asahi.enable = true;
    machines.asahi.enable = true;

    users.daniel.enable = true;
    users.daniel.graphical = true;
    users.daniel.sudo = true;
  };
}
