{ config, pkgs, lib, ... }: {
  options.programs.widevine.enable = lib.mkEnableOption "widevine";
config = let cfg = config.programs.widevine;
   in lib.mkIf cfg.enable {
	programs.firefox.profiles.default.settings = {
	     "media.gmp-widevinecdm.version" = pkgs.widevine-cdm.version;
	     "media.gmp-widevinecdm.visible" = true;
	     "media.gmp-widevinecdm.enabled" = true;
	     "media.gmp-widevinecdm.autoupdate" = false;
	     "media.eme.enabled" = true;
	     "media.eme.encrypted-media-encryption-scheme.enabled" = true;
	}; 
	home.file."firefox-widevinecdm" = {
	  enable = true;
	  target = ".mozilla/firefox/default/gmp-widevinecdm";
	  source = pkgs.runCommandLocal "firefox-widevinecdm" { } ''
	    out=$out/${pkgs.widevine-cdm.version}
	    mkdir -p $out
	    ln -s ${pkgs.widevine-cdm}/manifest.json $out/manifest.json
	    ln -s ${pkgs.widevine-cdm}/libwidevinecdm.so $out/libwidevinecdm.so
	  '';
	  recursive = true;
	};
};
}
