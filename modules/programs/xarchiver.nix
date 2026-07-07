{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.framework.programs.xarchiver;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.xarchiver = {
    enable = mkEnableOption "install xArchiver";
    default = mkEnableOption "add xArchiver as the default compressed-archive handler" // {default = true;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${primaryUser} = {
      home.packages = [pkgs.xarchiver];
    };

    framework.defaults.zip = {
      cmd = "xarchiver";
      desktop = "xarchiver";
    };
  };
}
