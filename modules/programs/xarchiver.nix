{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.xarchiver;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.xarchiver = {
    enable = lib.mkEnableOption "install xArchiver";
    default = lib.mkEnableOption "add xArchiver as the default compressed-archive handler" // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.user.${primaryUser} = {
      home.packages = [pkgs.xarchiver];
    };

    framework.defaults.zip = {
      cmd = "xarchiver";
      desktop = "xarchiver";
    };
  };
}
