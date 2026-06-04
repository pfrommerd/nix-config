{ config, lib, pkgs, ... }:

let
  cfg = config.services.vllm;
  cudaPkgs = pkgs.extend (
    _final: prev: {
      python3Packages = prev.python3Packages.overrideScope (
        pyFinal: pyPrev: {
          torch = pyPrev.torch.override { cudaSupport = true; };
          flashinfer = pyPrev.flashinfer.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // { broken = false; };
            torch = pyFinal.torch;
          });
          vllm = pyPrev.vllm.override {
            cudaSupport = true;
            torch = pyFinal.torch;
            flashinfer = pyFinal.flashinfer;
          };
        });
    }
  );
  mkVllmPackage =
    python3Packages:
    python3Packages.toPythonApplication python3Packages.vllm;
in
{
  options.services.vllm = {
    enable = lib.mkEnableOption "vLLM OpenAI-compatible API server";

    cudaSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use a CUDA-enabled vLLM package.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = mkVllmPackage (
        if cfg.cudaSupport
        then cudaPkgs.python3Packages
        else pkgs.python3Packages
      );
      defaultText = lib.literalExpression ''
        if config.services.vllm.cudaSupport
        then <CUDA-enabled vLLM package>
        else pkgs.vllm
      '';
      description = ''
        vLLM package to use. By default this is derived from
        `services.vllm.cudaSupport`; override it to provide a custom vLLM
        package.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      description = "Hugging Face model name or local path to serve.";
      example = "Qwen/Qwen2.5-7B-Instruct";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for vLLM to bind to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port for vLLM to listen on.";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Additional arguments passed to `vllm serve`.";
      example = [ "--tensor-parallel-size" "2" ];
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      description = "Environment variables for the vLLM service.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "vllm";
      description = "User account under which vLLM runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "vllm";
      description = "Group under which vLLM runs.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the vLLM port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = "/var/lib/vllm";
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.vllm = {
      description = "vLLM OpenAI-compatible API server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        HOME = "/var/lib/vllm";
        HF_HOME = "/var/cache/vllm/huggingface";
      } // cfg.environment;

      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([
          "${cfg.package}/bin/vllm"
          "serve"
          cfg.model
          "--host"
          cfg.host
          "--port"
          (toString cfg.port)
        ] ++ cfg.extraArgs);
        Restart = "on-failure";
        RestartSec = "10s";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "vllm";
        CacheDirectory = "vllm";
        WorkingDirectory = "/var/lib/vllm";
      };
    };
  };
}
