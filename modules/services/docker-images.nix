{ config, lib, pkgs, ... }:
let
  cfg = config.distro.services.docker-images;

  imageType = lib.types.submodule ({ name, ... }: {
    options = {
      image = lib.mkOption {
        type = lib.types.package;
        description = "Executable dockerTools stream image derivation.";
      };

      imageName = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Image name expected after loading the stream.";
      };

      tag = lib.mkOption {
        type = lib.types.str;
        default = "latest";
        description = "Image tag expected after loading the stream.";
      };

      wantedBy = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Systemd units that should pull in this image loader.";
      };
    };
  });

  validComponent = value: builtins.match "[a-zA-Z0-9][a-zA-Z0-9_.-]*" value != null;

  mkLoader = name: imageCfg:
    let
      imageKey = builtins.substring 0 32 (
        builtins.hashString "sha256" "${imageCfg.image}"
      );
      imageRef = "${imageCfg.imageName}:${imageCfg.tag}";
    in
    lib.nameValuePair "docker-load-${name}" {
      description = "Load the ${imageRef} Docker image";
      inherit (imageCfg) wantedBy;
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      restartTriggers = [ imageCfg.image ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "nixos-docker-images";
      };

      script = ''
        marker_dir=/var/lib/nixos-docker-images
        marker="$marker_dir/${name}-${imageKey}"

        if test -e "$marker" \
          && ${lib.getExe pkgs.docker} image inspect ${lib.escapeShellArg imageRef} >/dev/null 2>&1; then
          exit 0
        fi

        ${imageCfg.image} | ${lib.getExe pkgs.docker} load

        ${pkgs.findutils}/bin/find "$marker_dir" \
          -maxdepth 1 -type f -name ${lib.escapeShellArg "${name}-*"} -delete
        ${pkgs.coreutils}/bin/touch "$marker"
      '';
    };
in
{
  options.distro.services.docker-images = lib.mkOption {
    type = lib.types.attrsOf imageType;
    default = { };
    description = "Nix-built Docker images to load declaratively.";
  };

  config = lib.mkIf (cfg != { }) {
    assertions = lib.concatLists (lib.mapAttrsToList (name: imageCfg: [
      {
        assertion = validComponent name;
        message = "distro.services.docker-images image keys must be safe path and systemd name components";
      }
      {
        assertion = validComponent imageCfg.imageName;
        message = "distro.services.docker-images.${name}.imageName must be a simple local Docker image name";
      }
      {
        assertion = validComponent imageCfg.tag;
        message = "distro.services.docker-images.${name}.tag must be a simple Docker tag";
      }
    ]) cfg);

    virtualisation.docker.enable = true;
    systemd.services = lib.mapAttrs' mkLoader cfg;
  };
}
