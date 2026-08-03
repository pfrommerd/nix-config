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
  outputs = { self, nixpkgs, home-manager,  ... } @ inputs :
  let mkSystem = import ./mksystem.nix {
        inherit self inputs;
      };
      lib = nixpkgs.lib;
      configs = (import ./configs.nix);

      overlay = import ./overlay.nix inputs;
      # Names only, so this never forces a package that the platform can't
      # evaluate. Applying the overlay to empty sets is safe for attrNames.
      overlayPackageNames = builtins.attrNames (overlay { } { });
      pkgsFor = platform: import nixpkgs {
        system = platform;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
          cudaSupport = true;
        };
        overlays = [ overlay ];
      };

      # Only the systems this repo actually targets. Exposing all of
      # lib.systems.flakeExposed meant `nix flake check --all-systems` had to
      # evaluate packages.armv6l-linux.update and friends, where uv is broken.
      platforms = lib.unique (
        [ homeSystem ] ++ lib.mapAttrsToList (name: config: config.system) configs
      );
      eachPlatform = lib.genAttrs platforms;

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
          pkgs = pkgsFor homeSystem;
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

  in  {
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
        pkgs = pkgsFor platform;
        # get the coreutils packages
        bash = pkgs.bash;
        # Every package overlay.nix adds, on every platform that supports it, so
        # a broken package fails CI even when no host happens to pull it in.
        # meta.platforms is what gates this, so a package that genuinely cannot
        # build somewhere (widevine-cdm on darwin) has to say so in its meta.
        overlayPackages = builtins.filter
          (pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg)
          (map (name: pkgs.${name}) overlayPackageNames);
        platformHosts = (lib.mapAttrs (name: host: mkSystem host)
          (lib.filterAttrs (name: config: config.system == platform) configs));
        platformCi = lib.mapAttrs
          (name: host:
            let
              hostCi = (host.config.distro or {}).ci or {};
            in
              if platform == "aarch64-linux" then
                builtins.removeAttrs hostCi [ "machine" ]
              else
                hostCi
          )
          platformHosts;
        # `nix run .#update` refreshes every pkgs/*/sources.json in the working
        # tree by invoking each package's update.py (see ./update.sh).
        update = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = [ pkgs.uv pkgs.nix pkgs.nix-prefetch-github pkgs.git ];
          text = builtins.readFile ./update.sh;
        };
      in {
        inherit update;
        ci = derivation {
            name = "${platform}-ci";
            builder = "${bash}/bin/bash";
            args = [ "-c" "echo checked! > $out" ];
            system = platform;
            inputs = overlayPackages ++ (attrValuesRecursive platformCi);
        };
      }
    );
    # expose all of the packages from the nixpkgs
    legacyPackages = eachPlatform pkgsFor;
  };
}
