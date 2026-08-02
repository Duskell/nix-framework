{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.framework.desktop.graphics.kvantum;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.desktop.graphics.kvantum = {
    enable = lib.mkEnableOption "Enable the Kvantum qt theming engine";

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "General configuration settings for Kvantum.";
    };

    themes = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression ''
        with pkgs; [
          gruvbox-kvantum
          catppuccin-kvantum
        ]'';
      description = ''
        Theme packages to install to {file}`$XDG_CONFIG_HOME/Kvantum/`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = {
      qt.enable = true;
      qt.kvantum = {
        enable = true;

        settings =
          {
          }
          // cfg.settings;

        themes = cfg.themes;
      };
    };
  };
}
