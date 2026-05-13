{ config, pkgs, lib, ... }: {
  options = {
    distro.containers = {
      enable = lib.mkEnableOption "containers";
      # The container bridge name
      bridge = lib.mkOption {
        type = lib.types.str;
        default = "br0";
      };
      # The host ip mappings
      hosts = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Internal host to ip address mappings";
      };
    };
  };
  config = let
        cfg = config.distro.containers;
      in lib.mkIf cfg.enable {
    # If containers are enabled, we need to set up the network bridge
    networking = {
      bridges.br0.interfaces = [];
      interfaces.${cfg.bridge} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "172.17.0.1";
          prefixLength = 16;
        }];
      };
    };
  };
}
