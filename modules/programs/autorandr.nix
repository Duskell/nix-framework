{
  config,
  lib,
  framework,
  ...
}: let
  cfg = config.framework.programs.autorandr;
  primtaryUser = config.framework.primtaryUser;
in {
  options.framework.programs.autorandr = {
    enable = lib.mkEnableOptions "enable autorandr";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primtaryUser} = {
      programs.autorandr = {
        enable = true;
      };
    };
  };
}
