{ config, pkgs, lib, inputs, cosmicLib, ...}:
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
          suspend_on_battery_time = cosmicLib.cosmic.mkRON "optional" (15*60000);
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
          plugins_wings = mkRON "optional" (mkRON "tuple" [
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
          ]);
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
            value = [./wallpaper.jpg];
          };
        }
      ];
      shortcuts = let mkopts = mod: [
        # open terminal + browser + launcher
        { key = "${mod}+Return"; action = mkRON "enum" { value = [ "cosmic-term" ]; variant = "Spawn"; }; }
        { key = "${mod}+C"; action = mkRON "enum" { value = [ "firefox" ]; variant = "Spawn"; }; }
        { key = "${mod}"; action = mkRON "enum" "Disable"; }
        { key = "${mod}+D"; action = mkRON "enum" { variant = "Spawn"; value = [ "cosmic-launcher" ];};}
        # window management
        { key = "${mod}+Q"; action = mkRON "enum" "Close"; }
        # window navigation
        { key = "${mod}+H"; action = mkRON "enum" "Disable"; }
        { key = "${mod}+Shift+H"; action = mkRON "enum" "Disable"; }
        { key = "${mod}+Ctrl+Alt+H"; action = mkRON "enum" "Disable"; }
        { key = "${mod}+semicolon"; action = mkRON "enum" { variant = "Focus"; value = [(mkRON "enum" "Right")]; }; }
        { key = "${mod}+Shift+semicolon"; action = mkRON "enum" { variant = "Move"; value = [(mkRON "enum" "Right")]; }; }
        { key = "${mod}+semicolon"; action = mkRON "enum" { variant = "Focus"; value = [(mkRON "enum" "Right")]; }; }
        { key = "${mod}+Shift+semicolon"; action = mkRON "enum" { variant = "Move"; value = [(mkRON "enum" "Right")]; }; }
        { key = "${mod}+J"; action = mkRON "enum" { variant = "Focus"; value = [(mkRON "enum" "Left")]; }; }
        { key = "${mod}+Shift+J"; action = mkRON "enum" { variant = "Move"; value = [(mkRON "enum" "Left")]; }; }
        { key = "${mod}+K"; action = mkRON "enum" { variant = "Focus"; value = [(mkRON "enum" "Down")]; }; }
        { key = "${mod}+Shift+K"; action = mkRON "enum" { variant = "Move"; value = [(mkRON "enum" "Down")]; }; }
        { key = "${mod}+L"; action = mkRON "enum" { variant = "Focus"; value = [(mkRON "enum" "Up")]; }; }
        { key = "${mod}+Shift+L"; action = mkRON "enum" { variant = "Move"; value = [(mkRON "enum" "Up")]; }; }
        # workspace expose
        { key = "${mod}+W"; action = mkRON "enum" { variant = "System"; value = [(mkRON "enum" "WorkspaceOverview")];}; }
        # workspace navigation
        { key = "${mod}+1"; action = mkRON "enum" { variant = "Workspace"; value = [1];}; }
        { key = "${mod}+2"; action = mkRON "enum" { variant = "Workspace"; value = [2];}; }
        { key = "${mod}+3"; action = mkRON "enum" { variant = "Workspace"; value = [3];}; }
        { key = "${mod}+4"; action = mkRON "enum" { variant = "Workspace"; value = [4];}; }
        { key = "${mod}+5"; action = mkRON "enum" { variant = "Workspace"; value = [5];}; }
        { key = "${mod}+6"; action = mkRON "enum" { variant = "Workspace"; value = [6];}; }
        { key = "${mod}+7"; action = mkRON "enum" { variant = "Workspace"; value = [7];}; }
        { key = "${mod}+8"; action = mkRON "enum" { variant = "Workspace"; value = [8];}; }
        { key = "${mod}+9"; action = mkRON "enum" { variant = "Workspace"; value = [9];}; }
      ]; in (mkopts "Super") ++ (mkopts "Alt");
    };
  };
}
