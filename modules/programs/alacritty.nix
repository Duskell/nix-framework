{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos-framework.programs.alacritty;
  primaryUser = config.nixos-framework.primaryUser;
in
{
  options.nixos-framework.programs.alacritty = {
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

    home-manager.users.${primaryUser} =
      { config, ... }:
      {
        programs.alacritty = {
          enable = true;

          settings = {
            window = {
              padding = {
                x = 12;
                y = 12;
              };

              blur = true;
            };
          };
        };
      };
  };
}
