{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager.url = "github:HeitorAugustoLN/cosmic-manager";
    cosmic-manager.inputs.nixpkgs.follows = "nixpkgs";
    cosmic-manager.inputs.home-manager.follows = "home-manager";

    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, nix-darwin, ... } @ inputs :
  let mkSystem = import ./mksystem.nix {
        inherit self inputs;
      };
      lib = nixpkgs.lib;
      configs = (import ./configs.nix);

      platforms = lib.systems.flakeExposed;
      eachPlatform = lib.genAttrs platforms;

      systems = lib.mapAttrsToList (name: config: config.system);
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      attrValuesRecursive = set:
            let
              # Get top-level values
              values = builtins.attrValues set;
              filter = x: builtins.isAttrs x && !(lib.isDerivation x);
              # Filter for nested sets to recurse into
              nestedSets = builtins.filter filter values;
              # Filter for actual non-set values at this level
              leafValues = builtins.filter (x: !filter x) values;
            in
              leafValues ++ (builtins.concatMap attrValuesRecursive nestedSets);

      # For now hardcode all standalone homes as x86_64-linux
      homeSystem = "x86_64-linux";
      util = import ./util;
      mkHomeConfiguration = user: graphical:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = homeSystem;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              cudaSupport = true;
            };
            overlays = [(import ./overlay.nix inputs)];
          };
          extraSpecialArgs = {
            inherit inputs util;
            framework = "home-manager";
          };
          modules = [
            inputs.agenix.homeManagerModules.default
            ./users/${user}/home.nix
            { config = {
              home.username = user;
              home.homeDirectory = "/home/${user}";
              graphical = graphical;
            }; }
          ];
        };
      users = builtins.attrNames (lib.filterAttrs (name: type: type == "directory" && builtins.pathExists ./users/${name}/home.nix) (builtins.readDir ./users));
      homeConfigurationsForUser = user: {
        name = user;
        value = mkHomeConfiguration user false;
      };
      graphicalHomeConfigurationsForUser = user: {
        name = "${user}-graphical";
        value = mkHomeConfiguration user true;
      };

  in rec {
    nixosConfigurations = builtins.mapAttrs (name: host: mkSystem host)
         (lib.filterAttrs (name: config: config.system != "aarch64-darwin" &&
                                   config.system != "x86_64-darwin") configs);
    darwinConfigurations = builtins.mapAttrs (name: host: mkSystem host)
      	 (lib.filterAttrs (name: config: config.system == "aarch64-darwin" ||
                                        config.system == "x86_64-darwin") configs);
    homeConfigurations = builtins.listToAttrs (
      (map homeConfigurationsForUser users) ++ (map graphicalHomeConfigurationsForUser users)
    );
    # The jobsets
    packages = eachPlatform (platform:
      let
        # get the coreutils packages
        bash = nixpkgs.legacyPackages.${platform}.bash;
        platformHosts = (lib.mapAttrs (name: host: mkSystem host)
          (lib.filterAttrs (name: config: config.system == platform) configs));
      in if platformHosts == {} then {} else {
        ci = derivation {
            name = "${platform}-ci";
            builder = "${bash}/bin/bash";
            args = [ "-c" "echo checked! > $out" ];
            system = platform;
            inputs = attrValuesRecursive (lib.mapAttrs
                (name: host: (host.config.distro or {}).ci or {})
                platformHosts
            );
        };
      }
    );
    # expose all of the packages from the nixpkgs
    legacyPackages = eachPlatform (
        platform: import nixpkgs {
          system = platform;
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
            cudaSupport = true;
          };
	      overlays = [(import ./overlay.nix inputs)];
        }
      );
  };
}
