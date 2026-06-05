{ lib, config, pkgs, ... }:
{
  imports = [
    # our user-specific graphical options
    ./graphical
    ../modules/pi-coding-agent.nix
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
      preferDark = true;
      accent = "lavender";
      light.preset = "latte";
      dark.preset = "mocha";
      defaultOpacity = 0.85;
      editor.opacity = 0.9;
      terminal.opacity = 0.80;
      terminal.borderless = true;
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
      sandbox = {
        enabled = true;
        network = {
          allowedDomains = [
            "npmjs.org" "*.npmjs.org"
            "registry.npmjs.org" "registry.yarnpkg.com"
            "pypi.org" "*.pypi.org" "pip.pypa.io"
            "pythonhosted.org" "*.pythonhosted.org"
            "files.pythonhosted.org" "bootstrap.pypa.io"
            "github.com" "*.github.com" "api.github.com" "raw.githubusercontent.com"
          ];
          deniedDomains = [ ];
        };
        filesystem = {
          denyRead = ["~/.ssh" "~/.aws" "~/.gnupg"];
          allowWrite = ["." "/tmp"];
          denyWrite = [".env"];
        };
        slurm.enabled = true;
        gpu.enabled = true;
      };
      settings = {
        quietStartup = true;
        packages = [
          "git:git@github.com:pfrommerd/pi-sandbox.git"
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
