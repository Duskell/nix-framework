{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.vicinae;
in {
  options.framework.programs.vicinae = {
    enable = lib.mkEnableOption "install vicinae";

    default = lib.mkEnableOption "Add vicinae as the default launcher" // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    framework.defaults.browser = mkIf cfg.default {
      cmd = "vicinae toggle";
      desktop = null;
    };

    home-manager.users.${config.framework.primaryUser} = {config, ...}: {
      programs.vicinae.enable = true;
    };
  };
}
