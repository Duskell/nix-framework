# Wiki: https://nixos.wiki/wiki/Thunar
{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.thunar;
in {
  options.framework.programs.thunar = {
    enable = lib.mkEnableOption "install Thunar";
    default = lib.mkEnableOption "add Thunar as  the default file-editor" // {default = true;};
  };

  config = mkIf cfg.enable {
    services.dbus.packages = mkIf (cfg.default) mkDefault [pkgs.xfce.thunar];
    programs.thunar.enable = true;
    programs.thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];

    framework.defaults.fileManager = {
      cmd = "thunar";
      desktop = "thunar";
    };

    services.gvfs.enable = mkDefault true; # Mount, trash, and other functionalities
    services.tumbler.enable = mkDefault true; # Thumbnail support for images
  };
}
