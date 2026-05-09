{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge mkOption;
  inherit (nixos-framework.lib) desktops;
  cfg = config.nixos-framework.desktop.ly;
in
{
  options.nixos-framework.desktop.ly = {
    enable = lib.mkEnableOption "whether to enable ly as the display manager";

    package = mkOption {
      type = lib.package;
      default = pkgs.ly;
      description = "the ly package to use";
    };

    config = mkOption {
      type = lib.attrset;
      default = {};
      description = "extra settings merged in and overwriting defaults in config.ini.";
    };
  };

  config =
    let
      de = desktops.environmentByName config.nixos-framework.desktop.environment;
      wayland = desktops.usesWayland de;
    in
    mkIf cfg.enable (mkMerge [

      {
        services.displayManager.ly.enable = true;
        services.displayManager.ly.settings = cfg.config;
        services.displayManager.ly.package = cfg.package;
        services.displayManager.ly.x11support = !wayland;
      }

    ]);
}