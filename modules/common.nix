{
  config,
  pkgs,
  lib,
  ...
}:
{

  options.distro.common.enable = lib.mkEnableOption "Enable common presets";
  options.distro.common.proxy = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
  };
  options.distro.ci = lib.mkOption {
    type = with lib.types; attrs;
    description = "The CI package set";
    default = { };
  };

  config =
    let
      cfg = config.distro.common;
    in
    lib.mkIf cfg.enable {

      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      virtualisation.docker.enable = true;

      # Common to all "flavors"
      services.tailscale.enable = lib.mkOverride 500 true;
      services.resolved.enable = lib.mkOverride 500 true;
      services.openssh.enable = lib.mkOverride 500 true;

      # for tailscale exit node
      networking.firewall.checkReversePath = "loose";
      services.tailscale.useRoutingFeatures = "both";

      programs.fish.enable = true;
      users.mutableUsers = false;

      environment.systemPackages = with pkgs; [
        attic-client
        macchina
      ];

      fonts.packages = with pkgs; [ powerline-fonts powerline-symbols font-awesome ];

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = [
        pkgs.libGL
        pkgs.glib
        pkgs.libcxx
        pkgs.libgcc
        pkgs.stdenv.cc.cc.lib
      ];

      programs.command-not-found.enable = false;
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      i18n.defaultLocale = "en_US.UTF-8";

      # link /etc/ssl/cert.pem to /etc/ssl/certs/ca-bundle.crt
      # as nix uses a different location for the root certificate
      environment.etc.certfile = {
        source = "/etc/ssl/certs/ca-bundle.crt";
        target = "ssl/cert.pem";
      };

      distro.ci = {
        machine = config.system.build.toplevel;
        applications = {
          fish = config.programs.fish.package;
          tailscale = config.services.tailscale.package;
          attic = pkgs.attic-client;
        };
      };

      # Caddy proxy and TLS configuration
      # install our custom root certificate
      age.secrets.root-crt.file = ../secrets/root-crt.age;
      age.secrets.root-key.file = ../secrets/root-key.age;
      security.pki.certificateFiles = [ ../secrets/root.crt ];
      services.caddy = {
        enable = cfg.proxy != { };
        globalConfig = ''
          pki {
            ca vlan {
              name "Internal CA"
              root {
                format pem_file
                cert /etc/keys/root.crt
                key /etc/keys/root.key
              }
            }
          }'';
        virtualHosts = lib.mapAttrs (name: target: {
          extraConfig =
            if target == "helloworld" then
              ''
                tls { issuer internal { ca vlan } }
                respond "Hello, from ${name}"
              ''
            else
              ''
                tls { issuer internal { ca vlan } }
                reverse_proxy ${target}
              '';
        }) cfg.proxy;
      };
      environment.etc."keys/root.key" = lib.mkIf (cfg.proxy != { }) {
        source = config.age.secrets.root-key.path;
        mode = "0440";
        user = "caddy";
        group = "caddy";
      };
      environment.etc."keys/root.crt" = lib.mkIf (cfg.proxy != { }) {
        source = config.age.secrets.root-crt.path;
        mode = "0440";
        user = "caddy";
        group = "caddy";
      };
    };
}
