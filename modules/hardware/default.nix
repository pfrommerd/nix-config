{ modulsPath, ... }: {
  imports = [
    # Support utilities
    (modulesPath + "/installer/scan/not-detected.nix")
    ./apple-silicon-support

    # Individual machines
    ./asahi.nix
    ./athena.nix # darwin-machine
    ./kronos.nix
  ];
}
