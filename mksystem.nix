{ self, inputs }:

rawDistroConfig:

let system = rawDistroConfig.system;
    imports = rawDistroConfig.imports or [];
    util = import ./util;
    distroConfig = removeAttrs rawDistroConfig ["system" "imports"];

    isDarwin = system == "aarch64-darwin";
    framework = if isDarwin then "nix-darwin" else "nixos";

    agenix = inputs.agenix;
    pkgs = inputs.nixpkgs.legacyPackages."${system}";
    systemFunc = if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
    home-manager = if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

in systemFunc  {
  specialArgs = {
    inherit framework;
    inherit inputs;
    inherit util;
  };
  modules = [
    # Agenix module and cli
    (if isDarwin then agenix.darwinModules.default else agenix.nixosModules.default)
    {
      age.secrets.nix-netrc.file = ./secrets/attic-netrc.age;
    }
    # First set up nix
    ({config, ...}: {
      nixpkgs = {
        overlays = [(import ./overlay.nix inputs)];
        config.allowUnfree = true;
        hostPlatform = system;
      };
      nix = {
        settings.experimental-features = "nix-command flakes";
        settings.allowed-uris = [
          "github:"
          "git+https://github.com/"
          "git+ssh://github.com/"
        ];
        settings.substituters = ["https://packages.pfrommer.dev/default"];
        settings.trusted-public-keys = ["default:heutlqQBe82xcIMA03+dEtCYw0kvzQ1MCIJDX9EtABE="];
        settings.netrc-file = config.age.secrets.nix-netrc.path;
        package = pkgs.nixVersions.latest;
        registry.self.flake = self;
      };
    })
    {
      environment.systemPackages = [ agenix.packages.${system}.default ];
    }
    # Next, import home-manager module
    home-manager.home-manager
    {
      config = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inputs = inputs;
            framework = framework;
            util = util;
          };
        };
      };
    }
    # Lastly the distribution config (which uses our modules)
    {
      imports = imports;
      config.distro = distroConfig;
    }
    ({options, lib, ...}: lib.mkIf (options ? virtualisation.memorySize) {
      users.users.daniel.password = "testing";
    })
  ];
}
