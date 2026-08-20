{ lib, config, pkgs, ... }:
{
  imports = [
    # our user-specific graphical options
    ./graphical
    # custom program modules
    ../modules/ncdu.nix
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
      awscli fastfetch jujutsu minio-client ripgrep
      # latex + typst
      texliveFull typst
      # agentic tooling
      tmux cursor-cli
    ] ++ lib.optionals (!config.restricted) [ codex claude-code ]; # fmt: skip

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
    };
    programs.opencode = {
      enable = !config.restricted;
      package = pkgs.opencode;
      settings = {
        model = "llama-cpp/Qwen3.8-27B";
        provider.llama-cpp = {
          npm = "@ai-sdk/openai-compatible";
          name = "Kronos";
          options.baseURL = "https://chat.ts.pfrommer.dev/v1";
          models."Qwen3.8-27B" = {
            name = "Qwen3.8 27B Q4_K_M";
            reasoning = true;
            tool_call = true;
            interleaved.field = "reasoning_content";
            limit = {
              context = 65536;
              output = 16384;
            };
            modalities = {
              input = [ "text" ];
              output = [ "text" ];
            };
          };
        };
      };
    };
    programs.fish.enable = true;
    programs.ncdu.enable = true;
    programs.zellij.enable = true;
    programs.zellij.settings.show_startup_tips = false;

    home.stateVersion = "26.05";
  };
}
