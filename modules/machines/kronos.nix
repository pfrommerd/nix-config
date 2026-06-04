{ config, lib, pkgs, ... }:
{
  imports = [ ../common.nix ../vllm.nix ];
  options = {
    distro.machines.kronos.enable = lib.mkEnableOption "kronos configuration";
  };
  config = let
    cfg = config.distro.machines.kronos;
  in lib.mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = {
      features = {
        cdi = true;
      };
    };

    distro = {
      common.enable = true;
      ci = {};
    };

    # tailscale-enabled DNS server
    services.coredns = {
      enable = true;
      config = ''
        . {
            forward . 1.1.1.1 8.8.8.8 {
            	except ts.pfrommer.dev
            }
            hosts {
                100.96.208.99 kronos.ts.pfrommer.dev
                100.96.208.99 vllm-lite.ts.pfrommer.dev
                100.96.208.99 chat.ts.pfrommer.dev
                fallthrough
            }
            log
            errors
        }
      '';
    };
    services.open-webui = {
      enable = true;
      port = 11435;
      environment = {
        # OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      };
    };
    services.vllm = {
      enable = false;
      cudaSupport = true;
      port = 11434;
      model = "Qwen/Qwen2.5-7B-Instruct";
    };
    distro.common.proxy = {
      "vllm-lite.ts.pfrommer.dev" = "localhost:11434";
      "chat.ts.pfrommer.dev" = "localhost:11435";
    };
    # disable resolved so we can run coredns
    services.resolved.enable = false;
    systemd.services.coredns.serviceConfig = {
      # Disable dynamic user and make coredns
      # run as root so it can access the tailscale
      # unix socket
      DynamicUser = lib.mkForce false;
      User = "root";
      Group = "root";
    };
  };
}
