{ lib, config, pkgs, ... }:
{
  imports = [
    # our user-specific graphical options
    ./graphical
    # the custom theming module
    ../modules/theme
  ];

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
      texlive.combined.scheme-full typst
      # agentic tooling
      tmux cursor-cli
    ]; # fmt: skip

    home.sessionVariables = {
      EDITOR = "nvim";
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

    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = ''
        highlight Normal guibg=NONE
        set tabstop=4
        set expandtab
      '';
    };
    programs.pi-coding-agent = {
      enable = true;
      settings = {
        quietStartup = true;
        packages = [
          "git:git@github.com:pfrommerd/pi-autoresearch.git"
          "npm:@narumitw/pi-codex-usage"
        ];
        compaction = {
          enabled = true;
          reserveTokens = 16384;
        };
      };
    };

    programs.fish.enable = true;
    programs.zellij.enable = true;
    programs.zellij.settings.show_startup_tips = false;

    home.stateVersion = "26.05";
  };
}
