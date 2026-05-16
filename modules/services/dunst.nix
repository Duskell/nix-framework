{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf  mkEnableOption;
  cfg = config.framework.services.dunst;
in
{
  options.framework.services.dunst = {
    enable = mkEnableOption "enable dunst";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      services.dunst = {
        enable = true;
        settings = {
          global = {
            width = 350;
            height = 200;
            origin = "top-right";
            offset = "20x50";
            scale = 0;
            notification_limit = 5;
            
            font = "Sans 10";
            corner_radius = 15; 
            frame_width = 2;
            frame_color = "#740096";
          };
          urgency_low = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };
          urgency_normal = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
            timeout = 6;
          };
        };
      };
    };
  };
}