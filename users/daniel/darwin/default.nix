{ config, pkgs, lib, framework, ... }:
let darwin-scripts = pkgs.stdenv.mkDerivation {
    name = "darwin-scripts";
    version = "unstable";
    src = ./scripts;
    dontBuild = true;
    installPhase = ''
       mkdir $out
       cp -r . $out/bin
    '';
  }; 
in { 
  config = {
	  environment.systemPackages = [ darwin-scripts pkgs.fish ];
          system.primaryUser = "daniel";
	  services.skhd.enable = true;
	  services.skhd.package = pkgs.skhd.overrideAttrs (oldAttrs: {
	    propagatedBuildInputs = [pkgs.dash];
	    # Patch skhd to not use /bin/bash
	    postPatch = ''
	      substituteInPlace src/hotkey.c --replace-fail 'getenv("SHELL")' 'NULL'
	      SHKD_SHELL='${pkgs.dash}/bin/dash'
	      echo "Using shell: $SHKD_SHELL"
	      substituteInPlace src/hotkey.c --replace-fail '/bin/bash' $SHKD_SHELL
	    '';
	  });
	  services.skhd.skhdConfig = builtins.readFile ./skhd.config;

	  services.yabai.enable = true;
	  services.yabai.enableScriptingAddition = true;
	  services.yabai.config = {
	    focus_follows_mouse = "autoraise";
	    mouse_follows_focus = "off";

	    layout              = "bsp";
	    window_placement    = "second_child";
	    window_opacity      = "off";
	    top_padding         = 8;
	    bottom_padding      = 13;
	    left_padding        = 8;
	    right_padding       = 8;
	    window_gap          = 8;
	  };
	  services.jankyborders.enable = true;
	  services.jankyborders.active_color = "0xffc79e5d";
	  services.jankyborders.inactive_color = "0x00c79e5d";
	  services.jankyborders.width = 5.0;
	   
	  system.defaults.dock.autohide = true;
	  system.defaults.dock.autohide-delay = 2.0;
  };
}
