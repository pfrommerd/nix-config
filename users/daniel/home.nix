{ config, lib, pkgs, inputs, framework, ... }: {
  imports = [
    # our user-specific graphical options
    ./graphical
    # the custom theming module
    ../modules/theme
  ];

  config = {
    home.packages = with pkgs; [
      # python tooling
      uv
      # general tooling
      gnumake cmake clang clang-tools
      # general utilities
      unzip zip gnutar wget curl tree killall htop file
      dig tmux ffmpeg awscli fastfetch minio-client
      # latex + typst
      texlive.combined.scheme-full typst
      # cursor-cli
      cursor-cli
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
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
      editor.opacity = 0.85;
      terminal.opacity = 0.80;
      terminal.borderless = true;
    };

    programs.git.enable = true;
    programs.git.lfs.enable = true;
    programs.man.package = pkgs.man;

    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = ''highlight Normal guibg=NONE
                      set tabstop=4
                      set expandtab'';
    };
    programs.fish.enable = true;
    home.stateVersion = "26.05";
  };
}
