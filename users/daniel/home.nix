{ lib, config, pkgs, ... }:
{
  imports = [
    # our user-specific graphical options
    ./graphical
    # the custom theming module
    ../modules/theme
  ];

  options.restricted = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Trim config for locked-down systems (drop claude-code/codex/opencode)";
  };

  config = {
    home.packages = with pkgs; [
      # general tooling
      devcontainer nixd nil
      # languages tooling
      uv nodejs cargo gnumake
      cmake clang clang-tools
      # utilities
      unzip zip gnutar
      wget curl tree killall
      htop file dig ffmpeg
      awscli fastfetch minio-client ripgrep
      # latex + typst
      texliveFull typst
      # agentic tooling
      tmux cursor-cli
    ] ++ lib.optionals (!config.restricted) [ opencode codex claude-code ]; # fmt: skip

    home.sessionVariables = {
      EDITOR = "hx";
      COLORTERM = "truecolor";
    };

    # hf auth token
    age.secrets.daniel-hf-token = {
      file = ../../secrets/daniel-hf-token.age;
      path = "${config.xdg.configHome}/huggingface/token.txt";
    };

    distro.theme = {
      enable = true;
      preferDark = lib.mkDefault true;
      accent = "lavender";
      light.preset = "latte";
      dark.preset = "mocha";
      defaultOpacity = 0.85;
      editor.opacity = 0.9;
      terminal.opacity = 0.80;
      terminal.borderless = true;
    };

    specialisation = {
      dark.configuration.distro.theme.preferDark = true;
      light.configuration.distro.theme.preferDark = false;
    };

    programs.git.enable = true;
    programs.git.lfs.enable = true;
    programs.man.package = pkgs.man;

    programs.helix = {
      enable = true;
      package = pkgs.evil-helix;
      settings = {
        editor.indent-guides.render = true;
        keys =
          let
            movement = {
              j = "move_char_left";
              k = "move_visual_line_down";
              l = "move_visual_line_up";
              ";" = "move_char_right";
            };
          in
          {
            normal = movement // {
              s = "change_selection";
              H = "goto_window_top";
              M = "goto_window_center";
              L = "goto_window_bottom";
              D = [
                "ensure_selections_forward"
                "extend_to_line_end"
                "delete_selection"
              ];
            };
            # Ctrl-C leaves insert mode.
            insert = {
              C-c = "normal_mode";
            };
          };
      };
    };
    programs.fish.enable = true;
    programs.zellij.enable = true;
    programs.zellij.settings.show_startup_tips = false;

    home.stateVersion = "26.05";
  };
}
