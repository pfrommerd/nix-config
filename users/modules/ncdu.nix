{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ncdu;
in
{
  options.programs.ncdu = {
    enable = lib.mkEnableOption "ncdu";

    package = lib.mkPackageOption pkgs "ncdu" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
