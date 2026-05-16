{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  inherit (framework.lib) desktops;
  
  cfg = config.framework.services.flameshot;
  de = desktops.environmentByName config.framework.desktop.environment;
  wayland = if de != null then desktops.usesWayland de else false;
in
{
  options.framework.services.flameshot = {
    enable = mkEnableOption "install flameshot";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      services.flameshot = {
        enable = true;
        settings = {
          General = {
            savePath = "/home/${config.framework.primaryUser}/Screenshots";
            disabledTrayIcon = true;
            showStartupLaunchMessage = false;
            saveAsFileExtension = ".png";
            showDesktopNotification = true;
            showAbortNotification = false;
            showHelp = true;
            showSidePanelButton = true;

            uiColor = "#740096";
            contrastUiColor = "#270032";
            drawColor = "#ff0000";

            useGrimAdapter = wayland;
            disabledGrimWarning = wayland;
          };
        };
      };
    };
  };
}