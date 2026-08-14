# Wiki: https://nixos.wiki/wiki/Dolphin
{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.dolphin;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.dolphin = {
    enable = lib.mkEnableOption "install Dolphin";
    default = lib.mkEnableOption "add Dolphin as  the default file-editor" // {default = true;};
    quicklook-package.enable = lib.mkEnableOption "adds quicklook functionality to Dolphin";
  };

  config = mkIf cfg.enable {
    framework.defaults.fileManager = {
      cmd = "dolphin";
      desktop = "dolphin";
    };

    home-manager.users.${primaryUser} = {
      home.packages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.kio-admin
        (
          if cfg.quicklook-package.enable
          then dolphin-quicklook
          else kdePackages.dolphin
        )
      ];
    };
  };
}
