{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge;
  inherit (nixos-framework.lib) desktops;
  cfg = config.nixos-framework.desktop.i3;
in
{
  options.nixos-framework.desktop.i3 = {
    enable = lib.mkEnableOption "install i3 tiling desktop environment";

    themes = {
    #   vinyl = lib.mkEnableOption "install the Vinyl theme";
    };
  };

  config =
    let
      de = desktops.environmentByName config.nixos-framework.desktop.environment;
    in
    mkIf cfg.enable (mkMerge [

      {
        # Install i3
        services.xserver.windowManager.i3.enable = true;

        # Install extra packages.
        services.xserver.windowManager.i3.extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
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