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
  };

  config = mkIf cfg.enable {
    framework.defaults.fileManager = {
      cmd = "dolphin";
      desktop = "dolphin";
    };

    home-manager.users.${primaryUser} = {
      home.packages = with pkgs; [
        kdePackages.dolphin
        kdePackages.qtsvg
      ];
    };
  };
}
