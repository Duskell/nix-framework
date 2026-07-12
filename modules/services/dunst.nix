{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption mkPackageOption types;
  cfg = config.framework.services.dunst;

  themeType = types.submodule {
    options = {
      package = mkOption {
        type = types.package;
        example = lib.literalExpression "pkgs.adwaita-icon-theme";
        description = "Package providing the theme.";
      };

      name = mkOption {
        type = types.str;
        example = "Adwaita";
        description = "The name of the theme within the package.";
      };

      size = mkOption {
        type = types.str;
        default = "32x32";
        example = "16x16";
        description = "The desired icon size.";
      };
    };
  };
in {
  options.framework.services.dunst = {
    enable = mkEnableOption "the dunst notification daemon";

    package = mkPackageOption pkgs "dunst" {};

    configFile = mkOption {
      type = with types; nullOr (either str path);
      default = null;
      description = ''
        Path to the configuration file read by dunst.
        When set, dunst will be started with `-config <path>`, useful for live reloading mutable configs.
      '';
    };

    iconTheme = mkOption {
      type = themeType;
      default = {
        package = pkgs.hicolor-icon-theme;
        name = "hicolor";
        size = "32x32";
      };
      description = "Set the icon theme for notifications.";
    };

    waylandDisplay = mkOption {
      type = types.str;
      default = "";
      description = "Set the service's WAYLAND_DISPLAY environment variable.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Options set here are written directly into the dunstrc file.";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      services.dunst = {
        enable = true;
        inherit (cfg) package configFile iconTheme waylandDisplay;

        settings =
          lib.recursiveUpdate {
            global = {
              width = 350;
              height = 200;
              origin = "top-right";
              offset = "20x50";
              scale = 0;
              notification_limit = 5;

              corner_radius = 15;
              frame_width = 2;
              frame_color = "#740096";
            };
            urgency_normal = {
              timeout = 6;
            };
          }
          cfg.settings;
      };
    };
  };
}
