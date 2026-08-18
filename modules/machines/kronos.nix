{ config, lib, pkgs, ... }:
{
  imports = [ ../common.nix ];
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
                100.96.208.99 chat.ts.pfrommer.dev
                fallthrough
            }
            log
            errors
        }
      '';
    };
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp.override { cudaSupport = true; };
      settings = {
        host = "127.0.0.1";
        port = 11435;
        hf-repo = "unsloth/Qwen3.8-27B-GGUF:Q4_K_M";
        alias = "Qwen3.8-27B";
        no-mmproj = true;
        ctx-size = 65536;
        parallel = 1;
        gpu-layers = "all";
        fit = "off";
        sleep-idle-seconds = 300;
        flash-attn = "on";
        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
        spec-type = "draft-mtp";
        spec-draft-n-max = 2;
      };
    };
    distro.common.proxy = {
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
