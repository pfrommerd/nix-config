{
  config,
  pkgs,
  lib,
  inputs,
  cosmicLib,
  ...
}:
let
  inherit (cosmicLib.cosmic) mkRON;
  inherit (config.distro.theme) defaultOpacity;
in
{
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
  ];

  config = lib.mkIf (config.graphical && config.cosmic) {
    # terminal configuration
    programs.cosmic-term.enable = true;
    wayland.desktopManager.cosmic.configFile."com.system76.CosmicTerm" = {
      version = 1;
      entries.shortcuts_custom = mkRON "map" [
        {
          key = {
            modifiers = [
              (mkRON "enum" "Ctrl")
              (mkRON "enum" "Shift")
            ];
            key = "F";
          };
          value = mkRON "enum" "Disable";
        }
      ];
    };
    # desktop configuration
    wayland.desktopManager.cosmic = {
      enable = true;
      compositor = {
        autotile = true;
        autotile_behavior = mkRON "enum" "PerWorkspace";
        input_touchpad = {
          state = mkRON "enum" "Enabled";
          click_method = mkRON "optional" (mkRON "enum" "Clickfinger");
          disable_while_typing = mkRON "optional" true;
          scroll_config = mkRON "optional" {
            method = mkRON "optional" (mkRON "enum" "TwoFinger");
            natural_scroll = mkRON "optional" true;
            scroll_button = mkRON "optional" 2;
            scroll_factor = mkRON "optional" 1.0;
          };
        };
        workspaces = {
          workspace_mode = mkRON "enum" "OutputBound";
          workspace_layout = mkRON "enum" "Horizontal";
        };
      };
      idle = {
        screen_off_time = cosmicLib.cosmic.mkRON "optional" 120000;
        suspend_on_ac_time = cosmicLib.cosmic.mkRON "optional" null;
        suspend_on_battery_time = cosmicLib.cosmic.mkRON "optional" (15 * 60000);
      };
      applets = {
        time.settings = {
          first_day_of_week = 6;
          military_time = false;
          show_date_in_top_panel = true;
          show_seconds = false;
          show_weekday = true;
        };
      };
      panels = [
        {
          anchor = mkRON "enum" "Top";
          anchor_gap = false;
          margin = 0;
          expand_to_edges = true;
          name = "Panel";
          opacity = 0.75 * defaultOpacity;
          autohide = mkRON "optional" null;
          background = mkRON "enum" "ThemeDefault";
          size = mkRON "enum" "XS";
          output = mkRON "enum" "All";
          plugins_wings = mkRON "optional" (
            mkRON "tuple" [
              [
                "com.system76.CosmicAppletTime"
              ]
              [
                "com.system76.CosmicAppletStatusArea"
                "com.system76.CosmicAppletTiling"
                "com.system76.CosmicAppletAudio"
                "com.system76.CosmicAppletBluetooth"
                "com.system76.CosmicAppletNetwork"
                "com.system76.CosmicAppletBattery"
                "com.system76.CosmicAppletNotifications"
                "com.system76.CosmicAppletPower"
              ]
            ]
          );
          plugins_center = mkRON "optional" null;
        }
      ];
      wallpapers = [
        {
          output = "all";
          filter_by_theme = true;
          filter_method = mkRON "enum" "Lanczos";
          rotation_frequency = 600;
          sampling_method = mkRON "enum" "Alphanumeric";
          scaling_mode = mkRON "enum" "Stretch";
          source = mkRON "enum" {
            variant = "Path";
            value = [ ./wallpaper.jpg ];
          };
        }
      ];
      shortcuts =
        let
          shortcut = key: action: { inherit key action; };
          enumAction = key: variant: shortcut key (mkRON "enum" variant);
          spawn =
            key: command:
            shortcut key (
              mkRON "enum" {
                variant = "Spawn";
                value = [ command ];
              }
            );
          directional =
            variant: direction:
            mkRON "enum" {
              inherit variant;
              value = [ (mkRON "enum" direction) ];
            };
          focus = key: direction: shortcut key (directional "Focus" direction);
          move = key: direction: shortcut key (directional "Move" direction);
          system =
            key: action:
            shortcut key (
              mkRON "enum" {
                variant = "System";
                value = [ (mkRON "enum" action) ];
              }
            );
          workspace =
            key: number:
            shortcut key (
              mkRON "enum" {
                variant = "Workspace";
                value = [ number ];
              }
            );
          disable = key: enumAction key "Disable";

          mkopts = mod: [
            # open terminal + browser + launcher
            (spawn "${mod}+Return" "cosmic-term")
            (spawn "${mod}+C" "firefox")
            (disable "${mod}")
            (spawn "${mod}+D" "cosmic-launcher")

            # window management
            (enumAction "${mod}+Q" "Close")

            # window navigation
            (disable "${mod}+H")
            (disable "${mod}+Shift+H")
            (disable "${mod}+Ctrl+Alt+H")
            (focus "${mod}+semicolon" "Right")
            (move "${mod}+Shift+semicolon" "Right")
            (focus "${mod}+semicolon" "Right")
            (move "${mod}+Shift+semicolon" "Right")
            (focus "${mod}+J" "Left")
            (move "${mod}+Shift+J" "Left")
            (focus "${mod}+K" "Down")
            (move "${mod}+Shift+K" "Down")
            (focus "${mod}+L" "Up")
            (move "${mod}+Shift+L" "Up")

            # workspace expose
            (system "${mod}+W" "WorkspaceOverview")

            # workspace navigation
            (workspace "${mod}+1" 1)
            (workspace "${mod}+2" 2)
            (workspace "${mod}+3" 3)
            (workspace "${mod}+4" 4)
            (workspace "${mod}+5" 5)
            (workspace "${mod}+6" 6)
            (workspace "${mod}+7" 7)
            (workspace "${mod}+8" 8)
            (workspace "${mod}+9" 9)
          ];
        in
        (mkopts "Super") ++ (mkopts "Alt");
    };
  };
}
