{
  config,
  lib,
  framework,
  ...
}: let
  cfg = config.framework.services.kanshi;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.services.kanshi = {
    enable = lib.mkEnableOption "enable kanshi";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = {
      services.kanshi = {
        enable = true;
      };
    };
  };
}
