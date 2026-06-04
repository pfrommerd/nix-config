{
  config,
  lib,
  util,
  ...
}:
let
  cfg = config.distro.theme;

  blendRgb =
    hex: another: value:
    let
      a = util.colors.hex.to.srgb hex;
      b = util.colors.hex.to.srgb another;
      mix = channel: (1 - value) * a.${channel} + value * b.${channel};
    in
    util.colors.srgb.to.hex {
      r = mix "r";
      g = mix "g";
      b = mix "b";
      a = (1 - value) * a.a + value * b.a;
    };

  mkTheme =
    theme:
    let
      palette = theme.palette;
      accent = palette.${theme.accent};
      themeName = "distro-${lib.strings.toLower theme.name}";
    in
    {
      "$schema" =
        "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
      name = themeName;
      vars = {
        accent = accent;
        blue = palette.blue;
        green = palette.green;
        red = palette.red;
        yellow = palette.yellow;
        text = palette.text;
        gray = palette.subtext0;
        dimGray = palette.overlay0;
        darkGray = palette.surface0;
        selectedBg = palette.surface1;
        userMsgBg = palette.surface0;
        toolPendingBg = palette.mantle;
        toolSuccessBg = palette.crust;
        toolErrorBg = blendRgb palette.crust palette.red 0.10;
        customMsgBg = blendRgb palette.crust accent 0.08;
      };
      colors = {
        accent = "accent";
        border = "blue";
        borderAccent = accent;
        borderMuted = "darkGray";
        success = "green";
        error = "red";
        warning = "yellow";
        muted = "gray";
        dim = "dimGray";
        text = "text";
        thinkingText = "gray";

        selectedBg = "selectedBg";
        userMessageBg = "userMsgBg";
        userMessageText = "text";
        customMessageBg = "customMsgBg";
        customMessageText = "text";
        customMessageLabel = palette.mauve;
        toolPendingBg = "toolPendingBg";
        toolSuccessBg = "toolSuccessBg";
        toolErrorBg = "toolErrorBg";
        toolTitle = "text";
        toolOutput = "gray";

        mdHeading = palette.peach;
        mdLink = palette.blue;
        mdLinkUrl = "dimGray";
        mdCode = palette.teal;
        mdCodeBlock = palette.green;
        mdCodeBlockBorder = "gray";
        mdQuote = "gray";
        mdQuoteBorder = "dimGray";
        mdHr = "dimGray";
        mdListBullet = palette.teal;

        toolDiffAdded = "green";
        toolDiffRemoved = "red";
        toolDiffContext = "gray";

        syntaxComment = palette.overlay1;
        syntaxKeyword = palette.mauve;
        syntaxFunction = palette.blue;
        syntaxVariable = palette.text;
        syntaxString = palette.green;
        syntaxNumber = palette.peach;
        syntaxType = palette.yellow;
        syntaxOperator = palette.sky;
        syntaxPunctuation = palette.subtext1;

        thinkingOff = "darkGray";
        thinkingMinimal = palette.overlay0;
        thinkingLow = palette.blue;
        thinkingMedium = accent;
        thinkingHigh = palette.pink;
        thinkingXhigh = palette.yellow;

        bashMode = "green";
      };
      export = {
        pageBg = palette.crust;
        cardBg = palette.base;
        infoBg = palette.surface0;
      };
    };

  darkTheme = mkTheme cfg.dark;
  lightTheme = mkTheme cfg.light;
  activeTheme = if cfg.preferDark then darkTheme else lightTheme;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.file.".pi/agent/themes/${darkTheme.name}.json".text = builtins.toJSON darkTheme;
        home.file.".pi/agent/themes/${lightTheme.name}.json".text = builtins.toJSON lightTheme;
      }
      (lib.mkIf config.programs.pi-coding-agent.enable {
        programs.pi-coding-agent.settings.theme = activeTheme.name;
      })
    ]
  );
}
