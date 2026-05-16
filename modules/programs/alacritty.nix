{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.framework.programs.alacritty;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.alacritty = {
    enable = lib.mkEnableOption "install alacritty terminal";
  };

  config = lib.mkIf cfg.enable {
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          "alacritty.desktop"
        ];
      };
    };

    home-manager.users.${primaryUser} = {config, ...}: {
      programs.alacritty = {
        enable = true;

        settings = {
          window = {
            title = "Terminal";

            padding = {y = 5;};
            dimensions = {
              lines = 75;
              columns = 100;
            };
            blur = true;
          };
        };
      };
    };
  };
}
