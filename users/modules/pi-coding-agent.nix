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
        Settings are merged into {file}`<agentDir>/settings.json` during activation.
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Pi agent settings merged into {file}`~/.pi/agent/settings.json` during activation.
        See https://pi.dev/docs/latest/settings for available options.
      '';
    };

    extraFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Extra files to copy into the Pi agent directory during activation.
        Attribute names are paths relative to {option}`programs.pi-coding-agent.agentDir`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.mergePiCodingAgentSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      agent_dir="${config.home.homeDirectory}/${cfg.agentDir}"
      settings_file="$agent_dir/settings.json"
      managed_settings="${settingsFormat.generate "pi-agent-settings.json" cfg.settings}"

      mkdir -p "$agent_dir"
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: source: ''
        target="$agent_dir"/${lib.escapeShellArg name}
        mkdir -p "$(${pkgs.coreutils}/bin/dirname "$target")"
        rm -f "$target"
        install -m 0644 ${lib.escapeShellArg (toString source)} "$target"
      '') cfg.extraFiles)}

      tmp_file="$(mktemp "$agent_dir/settings.json.XXXXXX")"
      trap 'rm -f "$tmp_file"' EXIT

      if [ -e "$settings_file" ]; then
        if ! ${pkgs.jq}/bin/jq -e 'type == "object"' "$settings_file" >/dev/null; then
          echo "Cannot merge pi agent settings: $settings_file is not a JSON object" >&2
          exit 1
        fi

        ${pkgs.jq}/bin/jq -S -s '.[0] * .[1]' "$settings_file" "$managed_settings" > "$tmp_file"
      else
        cp "$managed_settings" "$tmp_file"
      fi

      chmod u+rw "$tmp_file"
      mv "$tmp_file" "$settings_file"
      trap - EXIT
    '';
  };
}
