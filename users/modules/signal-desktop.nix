{ config, pkgs, lib, ... }:  {
  options.programs.signal-desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable signal-desktop";
    };
  	package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.signal-desktop;
      defaultText = lib.literalExpression "pkgs.signal-desktop";
      description = "Signal Desktop package to install.";
    };
  };
  config = let cfg = config.programs.signal-desktop;
              in lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
