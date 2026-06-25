{
  # Fadetouched: a dark teal-green, earthy theme (authored in OKLCH).
  # Upstream: https://github.com/Arishawke/fadetouched-theme
  #
  # The upstream palette is a 12-step neutral ramp (n0 darkest -> n11 lightest)
  # plus 12 muted accents. We map those onto the existing Catppuccin-shaped
  # palette slots so every consumer of the palette keeps working unchanged:
  #
  #   neutrals  n11 n10 n9      n8       n7       n6       n5       n4       n3       n2   n1     n0
  #   slot      text subtext1 subtext0 overlay2 overlay1 overlay0 surface2 surface1 surface0 base mantle crust
  #
  #   accents   pink     magenta purple red  rust   orange yellow green teal cyan blue indigo
  #   slot      rosewater pink   mauve  red  maroon peach  yellow green teal sky  blue lavender
  #
  # flamingo and sapphire have no direct upstream counterpart; they are filled
  # with on-palette intermediates (salmon between rosewater/red, and a bright
  # blue between blue/sky) so the slot stays distinct for the other presets.
  name = "Fadetouched";
  dark = true;
  palette = {
    # accents
    rosewater = "#dbb5c1"; # upstream pink
    flamingo = "#d1979b"; # intermediate (rosewater <-> red)
    pink = "#c593af"; # upstream magenta
    mauve = "#af90c3"; # upstream purple
    red = "#c87a75"; # upstream red
    maroon = "#bc836c"; # upstream rust
    peach = "#d7a176"; # upstream orange
    yellow = "#d7be86"; # upstream yellow
    green = "#96bb93"; # upstream green
    teal = "#81b8a8"; # upstream teal
    sky = "#99c9c9"; # upstream cyan
    sapphire = "#8bb9cc"; # intermediate (blue <-> sky)
    blue = "#7daacf"; # upstream blue
    lavender = "#7d89bb"; # upstream indigo

    # neutrals (n11 -> n0)
    text = "#dee1df";
    subtext1 = "#b3b7b4";
    subtext0 = "#979d98";
    overlay2 = "#7e8580";
    overlay1 = "#666f6b";
    overlay0 = "#505a56";
    surface2 = "#3e4945";
    surface1 = "#2e3a36";
    surface0 = "#1f2d29";
    base = "#11201e";
    mantle = "#091816";
    crust = "#03100f";
  };
}
