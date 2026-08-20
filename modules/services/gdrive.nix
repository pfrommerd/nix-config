{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.distro.services.gdrive;
in
{
  options.distro.services.gdrive = {
    enable = lib.mkEnableOption "an rclone-backed Google Drive mount";

    encryptedConfigFile = lib.mkOption {
      type = lib.types.path;
      description = "Agenix-encrypted rclone configuration containing the configured remote.";
    };

    remote = lib.mkOption {
      type = lib.types.str;
      default = "gdrive:";
      description = "rclone remote and optional path to mount.";
    };

    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/data/gdrive";
      description = "Absolute path where the remote is mounted.";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/rclone-gdrive";
      description = "Directory used for rclone's VFS cache.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "User that owns and runs the mount.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "Group that owns and runs the mount.";
    };

    allowOther = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow users other than the mount owner to access the filesystem.";
    };

    extraArguments = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Additional arguments passed to rclone mount.";
    };

    package = lib.mkPackageOption pkgs "rclone" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.mountPoint;
        message = "distro.services.gdrive.mountPoint must be an absolute path";
      }
      {
        assertion = lib.hasPrefix "/" cfg.cacheDir;
        message = "distro.services.gdrive.cacheDir must be an absolute path";
      }
    ];

    age.secrets.rclone-gdrive = {
      file = cfg.encryptedConfigFile;
      owner = cfg.user;
      group = cfg.group;
    };

    environment.systemPackages = [ cfg.package ];
    programs.fuse = {
      enable = true;
      userAllowOther = cfg.allowOther;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0755 ${cfg.user} ${cfg.group} -"
      "d ${cfg.cacheDir} 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.rclone-gdrive = {
      description = "Google Drive mount at ${cfg.mountPoint}";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      # rclone invokes fusermount3 through PATH. On NixOS it must find the
      # setuid wrapper rather than the unprivileged binary in the Nix store.
      enableDefaultPath = false;
      environment.PATH = config.security.wrapperDir;
      serviceConfig = {
        Type = "notify";
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = "rclone-gdrive";
        RuntimeDirectoryMode = "0700";
        ExecStartPre = lib.escapeShellArgs [
          "${pkgs.coreutils}/bin/install"
          "-m"
          "0600"
          config.age.secrets.rclone-gdrive.path
          "/run/rclone-gdrive/rclone.conf"
        ];
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "mount"
            cfg.remote
            cfg.mountPoint
            "--config=/run/rclone-gdrive/rclone.conf"
          ]
          ++ lib.optional cfg.allowOther "--allow-other"
          ++ [
            "--dir-cache-time=1h"
            "--poll-interval=15s"
            "--vfs-cache-mode=writes"
            "--vfs-cache-max-age=24h"
            "--cache-dir=${cfg.cacheDir}"
            "--umask=0022"
          ]
          ++ cfg.extraArguments
        );
        ExecStop = "${config.security.wrapperDir}/fusermount3 -u ${cfg.mountPoint}";
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStopSec = "30s";
      };
    };
  };
}
