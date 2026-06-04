{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;
  settingsFormat = pkgs.formats.json { };
in
{
  options.programs.pi-coding-agent = {
    enable = lib.mkEnableOption "pi coding agent";

    package = lib.mkPackageOption pkgs "pi-coding-agent" { };

    agentDir = lib.mkOption {
      type = lib.types.str;
      default = ".pi/agent";
      description = ''
        Pi agent directory relative to the home directory.
        Settings are written to {file}`<agentDir>/settings.json`.
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Pi agent settings written to {file}`~/.pi/agent/settings.json`.
        See https://pi.dev/docs/latest/settings for available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file."${cfg.agentDir}/settings.json".source =
      settingsFormat.generate "pi-agent-settings.json" cfg.settings;
  };
}
