let
  srgb = import ./srgb.nix;
  oklch = import ./oklch.nix { inherit srgb; };
  hex = import ./hex.nix { inherit srgb oklch; };
in {
  inherit srgb oklch hex;
}
