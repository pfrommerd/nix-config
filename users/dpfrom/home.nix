{ config, pkgs, ... }:

{
  imports = [ ../daniel/home.nix ];
  config = {
    home.username = lib.mkDefault "dpfrom";
    home.homeDirectory = lib.mkDefault "/home/dpfrom";
  };
}
