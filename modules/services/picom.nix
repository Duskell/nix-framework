{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.framework.services.picom;
in
{
  options.framework.services.picom = {
    enable = mkEnableOption "enable picom, a compositor for X11";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;

      # Fading
      fade = true;
      fadeSteps = [ 0.09 0.09 ];
      fadeDelta = 5;

      # Shadows
      shadow = true;
      shadowOffsets = [ (-7) (-7) ];
      shadowOpacity = 0.7;
      shadowExclude = [
        "window_type *= 'normal' && ! name ~= ''"
        "class_g = 'Polybar'"
        "name = 'Polybar'"
        "window_type = 'dock'"
        "window_type = 'dnd'"
      ];

      # Opacity
      activeOpacity = 1.0;
      inactiveOpacity = 0.8;
      menuOpacity = 0.8;

      settings = {
        corner-radius = 15;

        blur-method = "dual_kawase";
        blur-strength = 5;
        
        blur-background-exclude = [ 
          "window_type = 'dock'" 
          "window_type = 'desktop'" 
        ];

        shadow-radius = 7;
        detect-client-opacity = true;
        detect-rounded-corners = true;
        detect-transient = true;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
      };
    };
  };
}