{ config, pkgs, lib, ... }:
let
  origConfig = config;
  paisa = pkgs.paisa;
in
{
  imports = [ ../containers ];
  options = {
    distro.containers.paisa = {
      enable = lib.mkEnableOption "Caddy web server reverse proxy";
      host = lib.mkOption {
        type = lib.types.str;
        default = "paisa";
      };
    };
  };
  config = let cfg = config.distro.containers; in
    lib.mkIf cfg.paisa.enable {

    distro.containers.enable = true;
    distro.containers.hosts = {
      paisa = "172.17.0.2";
    };
    distro.common.enable = true;
    distro.common.proxy = {
      ${cfg.paisa.host} = "paisa";
    };

    containers.paisa = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = cfg.bridge;
      localAddress = "172.17.0.2/16";
      bindMounts = {
        "/mnt" = { hostPath = "/home/daniel/Documents/personal/accounting"; isReadOnly = false;};
      };
      config = { config, pkgs, lib, ... }: {
        environment.systemPackages = [ paisa pkgs.hledger ];
        environment.etc."paisa.yaml" = {
          text = ''
            ledger_cli: hledger
            locale: en-US
            journal_path: /mnt/ledger.journal
            db_path: /var/lib/paisa/paisa.db
            default_currency: $
            financial_year_starting_month: 1
            user_accounts:
              - username: daniel # passwd is paisa_password
                password: sha256:2246c1e2768d31e1ab6fdda53d0ff83b95e001722e665a41b931393334040419
          '';
        };
        systemd.services.paisa = {
          enable = true;
          description = "Paisa";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStart = "${paisa}/bin/paisa serve --config /etc/paisa.yaml";
            Restart = "always"; RestartSec = "10";
            User = "paisa"; Group = "paisa";
          };
          path = [ paisa pkgs.hledger ];
        };
        networking.firewall.allowedTCPPorts = [ 80 ];
        users.groups.paisa = {};
        users.users.paisa = {
          isSystemUser = true;
          uid = 1000;
          group = "paisa";
          home = "/var/lib/paisa";
          createHome = true;
        };
        services.caddy = {
          enable = true;
          virtualHosts = {
            ":80".extraConfig = ''
              reverse_proxy http://localhost:7500
            '';
          };
        };
        system.stateVersion = "24.11";
      };
    };
  };
}
