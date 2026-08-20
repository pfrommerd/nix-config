{ config, lib, pkgs, ... }:
let
  cfg = config.distro.services.forgejo-runner;
  settingsFormat = pkgs.formats.yaml { };

  mkCiImage = {
    targetPkgs,
    architecture,
    system,
  }:
    let
      root = targetPkgs.buildEnv {
        name = "forgejo-ci-${system}-root";
        paths = with targetPkgs; [
          attic-client
          bashInteractive
          coreutils-full
          curl
          dockerTools.binSh
          dockerTools.caCertificates
          dockerTools.fakeNss
          findutils
          git
          gnugrep
          gnused
          gnutar
          gzip
          nix
          which
        ];
        pathsToLink = [ "/bin" "/etc" ];
        ignoreCollisions = true;
      };
    in
    targetPkgs.dockerTools.streamLayeredImage {
      name = "nix-config-forgejo-${system}";
      tag = "latest";
      inherit architecture;
      contents = [ root ];
      includeNixDB = true;
      extraCommands = ''
        mkdir -p root/.config/nix tmp workspace
        chmod 1777 tmp
        printf '%s\n' \
          'experimental-features = nix-command flakes' \
          'sandbox = false' \
          'build-users-group =' \
          > root/.config/nix/nix.conf
      '';
      config = {
        Cmd = [ "/bin/bash" ];
        WorkingDir = "/workspace";
        Env = [
          "HOME=/root"
          "NIX_PAGER=cat"
          "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
          "PATH=/bin"
          "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
          "USER=root"
        ];
      };
    };

  images = {
    x86_64-linux = mkCiImage {
      targetPkgs = pkgs;
      architecture = "amd64";
      system = "x86_64-linux";
    };
    aarch64-linux = mkCiImage {
      targetPkgs = pkgs.pkgsCross.aarch64-multiplatform;
      architecture = "arm64";
      system = "aarch64-linux";
    };
  };

  labels = lib.mapAttrsToList (
    system: _: "${system}:docker://nix-config-forgejo-${system}:latest"
  ) images;
  labelsString = lib.concatStringsSep "," labels;
  loaderUnits = map (system: "docker-load-forgejo-ci-${system}.service") (builtins.attrNames images);

  runnerConfig = settingsFormat.generate "forgejo-runner.yaml" {
    runner = {
      capacity = cfg.capacity;
      timeout = "3h";
    };
    container = {
      privileged = false;
      options = "--volume ${cfg.caBundle}:${cfg.caBundle}:ro";
      docker_host = "-";
      force_pull = false;
    };
  };

  runnerExe = lib.getExe cfg.package;
  registerScript = pkgs.writeShellScript "forgejo-register-runner" ''
    set -euo pipefail
    umask 077

    token_hash_file=.token-hash
    labels_file=.labels
    token_hash_current="$(printf '%s' "$TOKEN" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1)"
    token_hash_stored="$(${pkgs.coreutils}/bin/cat "$token_hash_file" 2>/dev/null || true)"
    labels_stored="$(${pkgs.coreutils}/bin/cat "$labels_file" 2>/dev/null || true)"

    if test ! -e .runner \
      || test "$token_hash_current" != "$token_hash_stored" \
      || test ${lib.escapeShellArg labelsString} != "$labels_stored"; then
      ${pkgs.coreutils}/bin/rm -f .runner
      ${runnerExe} register --no-interactive \
        --instance ${lib.escapeShellArg cfg.url} \
        --token "$TOKEN" \
        --name ${lib.escapeShellArg cfg.name} \
        --labels ${lib.escapeShellArg labelsString} \
        --config ${runnerConfig}
      printf '%s' "$token_hash_current" > "$token_hash_file"
      printf '%s' ${lib.escapeShellArg labelsString} > "$labels_file"
    fi
  '';
in
{
  imports = [ ./docker-images.nix ];

  options.distro.services.forgejo-runner = {
    enable = lib.mkEnableOption "a native Forgejo Actions runner";

    url = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:3000";
      description = "Forgejo instance URL used by the runner daemon.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Environment file containing TOKEN=<registration token>.";
    };

    tokenRestartTriggers = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = "Encrypted token sources that should restart and re-register the runner when changed.";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = "Name used to register the runner with Forgejo.";
    };

    capacity = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Maximum number of concurrent jobs accepted by this runner.";
    };

    caBundle = lib.mkOption {
      type = lib.types.str;
      default = "/etc/ssl/certs/ca-bundle.crt";
      description = "Host CA bundle mounted read-only into job containers.";
    };

    package = lib.mkPackageOption pkgs "forgejo-runner" { };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo.settings.actions.ENABLED = true;

    distro.services.docker-images = lib.mapAttrs' (system: image:
      lib.nameValuePair "forgejo-ci-${system}" {
        inherit image;
        imageName = "nix-config-forgejo-${system}";
        tag = "latest";
        wantedBy = [ "forgejo-runner.service" ];
      }
    ) images;

    systemd.services.forgejo-runner = {
      description = "Forgejo Actions Runner";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      requires = [ "docker.service" "forgejo.service" ];
      after = [
        "docker.service"
        "forgejo.service"
        "network-online.target"
      ] ++ loaderUnits;
      restartTriggers = [ runnerConfig cfg.package ] ++ cfg.tokenRestartTriggers;
      environment.HOME = "/var/lib/forgejo-runner";

      serviceConfig = {
        DynamicUser = true;
        User = "forgejo-runner";
        StateDirectory = "forgejo-runner";
        WorkingDirectory = "/var/lib/forgejo-runner";
        EnvironmentFile = cfg.tokenFile;
        SupplementaryGroups = [ "docker" ];
        ExecStartPre = [ registerScript ];
        ExecStart = "${runnerExe} daemon --config ${runnerConfig}";
        Restart = "on-failure";
        RestartSec = "2s";
        UMask = "0077";
      };
    };
  };
}
