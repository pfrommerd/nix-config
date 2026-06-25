{ config, lib, ... }:
let
  theme-presets = import ./presets;
  cfg = config.distro.theme;
in
{
  imports = [
    ./fish.nix
    ./zed.nix
    ./zellij.nix
    ./cosmic-term.nix
    ./cosmic-comp.nix
    ./helix.nix
    ./pi.nix
  ];
  options.distro.theme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable theme";
    };
    accent = lib.mkOption {
      type = lib.types.str;
      default = "lavender";
      description = "Accent color";
    };
    preferDark = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Prefer dark theme";
    };

    defaultOpacity = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Decoration opacity of windows.";
    };

    # terminal and editor specific overrides
    terminal = {
      opacity = lib.mkOption {
        type = lib.types.float;
        default = cfg.defaultOpacity;
        description = "Background opacity";
      };
      borderless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Borderless terminals, windows, etc.";
      };
    };
    editor = {
      opacity = lib.mkOption {
        type = lib.types.float;
        default = cfg.defaultOpacity;
        description = "Background opacity";
      };
    };

    # light and dark themes

    dark = {
      preset = lib.mkOption {
        type = lib.types.str;
        default = "mocha"; # default to mocha
        description = "Preset theme name";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = theme-presets.${cfg.dark.preset}.name;
        description = "Dark Theme name";
      };
      dark = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Is a Dark mode";
      };
      accent = lib.mkOption {
        type = lib.types.str;
        default = cfg.accent;
        description = "Accent color";
      };
      palette = lib.mkOption {
        type = lib.types.attrs;
        default = theme-presets.${cfg.dark.preset}.palette;
        description = "Palette";
      };
    };
    light = {
      preset = lib.mkOption {
        type = lib.types.str;
        default = "latte"; # default to gruvbox
        description = "Preset theme name";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = theme-presets.${cfg.light.preset}.name;
        description = "Light Theme name";
      };
      dark = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Is a Dark mode";
      };
      accent = lib.mkOption {
        type = lib.types.str;
        default = cfg.accent;
        description = "Accent color";
      };
      palette = lib.mkOption {
        type = lib.types.attrs;
        default = theme-presets.${cfg.light.preset}.palette;
        description = "Palette";
      };
    };
  };
}
