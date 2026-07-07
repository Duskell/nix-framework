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
    default = lib.mkEnableOption "add alacritty as the default terminal" // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    framework.defaults.terminal = lib.inheritmkIf cfg.default {
      cmd = "alacritty";
      desktop = "alacritty";
    };

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
