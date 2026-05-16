# Wiki: https://nixos.wiki/wiki/Thunar
{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.thunar;
in
{
  options.framework.programs.thunar = {
    enable = lib.mkEnableOption "install Thunar";
  };

  config = lib.mkIf cfg.enable {
    programs.thunar.enable =  true;
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
    services.gvfs.enable = cfg.thunar.enable; # Mount, trash, and other functionalities
    services.tumbler.enable = cfg.thunar.enable; # Thumbnail support for images
  };
}