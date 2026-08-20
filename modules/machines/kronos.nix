{ config, lib, pkgs, ... }:
{
  imports = [
    ../common.nix
    ../services/gdrive.nix
  ];
  options = {
    distro.machines.kronos.enable = lib.mkEnableOption "kronos configuration";
  };
  config = let
    cfg = config.distro.machines.kronos;
    forgejoDomain = "forgejo.ts.pfrommer.dev";
    forgejoExe = lib.getExe config.services.forgejo.package;
    forgejoConfig = "${config.services.forgejo.customDir}/conf/app.ini";
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
      services.gdrive = {
        enable = true;
        encryptedConfigFile = ../../secrets/rclone-gdrive.age;
        user = "daniel";
        group = "users";
      };
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
                100.96.208.99 ${forgejoDomain}
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

    services.forgejo = {
      enable = true;
      settings = {
        server = {
          DOMAIN = forgejoDomain;
          ROOT_URL = "https://${forgejoDomain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          SSH_DOMAIN = forgejoDomain;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };
    age.secrets.forgejo-admin-password = {
      file = ../../secrets/forgejo-admin-password.age;
      owner = config.services.forgejo.user;
      group = config.services.forgejo.group;
    };
    systemd.services.forgejo-bootstrap-admin = {
      description = "Create the initial Forgejo administrator";
      requires = [ "forgejo.service" ];
      after = [ "forgejo.service" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ config.age.secrets.forgejo-admin-password.file ];
      script = ''
        if ${forgejoExe} admin user list \
          --config ${lib.escapeShellArg forgejoConfig} \
          --work-path ${lib.escapeShellArg config.services.forgejo.stateDir} \
          | ${pkgs.gnugrep}/bin/grep -Eq '^[[:space:]]*[0-9]+[[:space:]]+pfrommerd([[:space:]]|$)'; then
          exit 0
        fi

        password="$(<${config.age.secrets.forgejo-admin-password.path})"
        ${forgejoExe} admin user create \
          --config ${lib.escapeShellArg forgejoConfig} \
          --work-path ${lib.escapeShellArg config.services.forgejo.stateDir} \
          --username pfrommerd \
          --email dan.pfrommer@gmail.com \
          --password "$password" \
          --admin \
          --must-change-password=false
        unset password
      '';
      serviceConfig = {
        Type = "oneshot";
        User = config.services.forgejo.user;
        Group = config.services.forgejo.group;
        WorkingDirectory = config.services.forgejo.stateDir;
        RemainAfterExit = true;
        UMask = "0077";
      };
    };
    distro.common.proxy = {
      "chat.ts.pfrommer.dev" = "localhost:11435";
      "${forgejoDomain}" = "localhost:3000";
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
