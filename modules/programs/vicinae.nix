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
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {config, ...}: {
      programs.vicinae.enable = true;
    };
  };
}

