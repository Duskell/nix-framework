{
  config,
  lib,
  framework,
  ...
}: let
  cfg = config.framework.programs.autorandr;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.autorandr = {
    enable = lib.mkEnableOption "enable autorandr";
  };

  config = lib.mkIf cfg.enable {
    services.autorandr.enable = true;

    home-manager.users.${primaryUser} = {
      programs.autorandr = {
        enable = true;
      };
    };
  };
}
