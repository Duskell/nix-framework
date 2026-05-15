{
  config,
  lib,
  pkgs,
  framework,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge;
  inherit (framework.lib) desktops;
  cfg = config.framework.desktop.i3;
in
{
  options.framework.desktop.i3 = {
    themes = {
      # vinyl = lib.mkEnableOption "install the Vinyl theme";
    };
  };

  config =
    let
      desktop = config.framework.desktop;
    in
    mkIf (desktop.enable && desktop.environment == "i3") (mkMerge [

      {
        # Install i3
        services.xserver.windowManager.i3.enable = true;

        # Install extra packages.
        services.xserver.windowManager.i3.extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
        ];

        xdg.portal.extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];

        programs.partition-manager.enable = true;
      }

    #   (mkIf cfg.themes.vinyl {
    #     environment.systemPackages = [
    #       pkgs.vinyl-theme
    #     ];
    #   })

    ]);
}