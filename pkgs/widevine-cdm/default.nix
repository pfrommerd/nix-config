{ stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  python3,
  squashfsTools,
  nspr
}:
let widevine-installer = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "widevine-installer";
    rev = "eab8c668ad3f9db27a444ee1f94b82d8f3ab5336";
    sha256 = "sha256-ox2xU7PraSexer7+M+4Bc5gxpRYr1d4elh1e6erpsUg=";
  };
  lacros-image = fetchurl {
    url = 
      let distfiles_base = "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles";
          lacros_name = "chromeos-lacros-arm64-squash-zstd";
          lacrosVersion = "120.0.6098.0";
      in "${distfiles_base}/${lacros_name}-${lacrosVersion}";
    hash = "sha256-OKV8w5da9oZ1oSGbADVPCIkP9Y0MVLaQ3PXS3ZBLFXY=";
  };
in stdenvNoCC.mkDerivation {
  name = "widevine";
  version = "4.10.2662.3";
  dontUnpack = true;
  dontBuild = true;

  buildInputs = [ python3 squashfsTools ];

  installPhase = ''
    mkdir $out
    unsquashfs -q ${lacros-image} 'WidevineCdm/*'
    python3 ${widevine-installer}/widevine_fixup.py squashfs-root/WidevineCdm/_platform_specific/cros_arm64/libwidevinecdm.so $out/libwidevinecdm.so
    mv squashfs-root/WidevineCdm/manifest.json $out/
    mv squashfs-root/WidevineCdm/LICENSE $out/
    patchelf --add-rpath ${nspr}/lib $out/libwidevinecdm.so 
  '';
}
