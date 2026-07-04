{
  config,
  lib,
  pkgs,
  inputs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkOption types mkDefault;
  cfg = config.framework.programs.stylix;
in {
  imports = [inputs.stylix.nixosModules.stylix];

  options.framework.programs.stylix = {
    enable = lib.mkEnableOption "Enable high-level Stylix theming engine";

    theme = mkOption {
      type = types.str;
      default = "horizon-dark";
      description = "Base16 scheme name (from base16-schemes)";
    };

    wallpaper = mkOption {
      type = types.path;
      default = "${framework}/assets/images/fever_dream.png";
      description = "Path to the wallpaper image file.";
    };

    polarity = mkOption {
      type = types.enum ["dark" "light" "either"];
      default = "dark";
    };

    opacity = {
      terminal = mkOption {
        type = types.float;
        default = 0.85;
      };
      popups = mkOption {
        type = types.float;
        default = 0.9;
      };
    };

    cursor = {
      name = mkOption {
        type = types.str;
        default = "Bibata-Modern-Ice";
      };
      size = mkOption {
        type = types.int;
        default = 24;
      };
    };

    fonts = {
      sizes = {
        applications = mkOption {
          type = types.int;
          default = 12;
        };
        terminal = mkOption {
          type = types.int;
          default = 13;
        };
        desktop = mkOption {
          type = types.int;
          default = 11;
        };
        popups = mkOption {
          type = types.int;
          default = 11;
        };
      };
    };

    disabledTargets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of targets to disable (e.g., [ 'vscode' 'discord' ])";
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      enableReleaseChecks = false;
      image = cfg.wallpaper;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";
      polarity = cfg.polarity;

      opacity = {
        terminal = cfg.opacity.terminal;
        popups = cfg.opacity.popups;
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };

      fonts = {
        serif = {
          package = pkgs.eb-garamond;
          name = "EB Garamond";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        sizes = cfg.fonts.sizes;
      };

      targets = {
        grub.enable = mkDefault true;
        grub.useWallpaper = mkDefault true;
        plymouth.enable = mkDefault false;
        console.enable = mkDefault true;
      };
    };

    environment.variables = {
      XCURSOR_SIZE = "${toString cfg.cursor.size}";
    };

    home-manager.users.${config.framework.primaryUser} = {
      stylix.targets = lib.genAttrs cfg.disabledTargets (name: {enable = false;});

      # gtk.gtk4.theme = null;
      qt = {
        enable = true;
        platformTheme.name = lib.mkDefault "gtk";
        style.name = lib.mkDefault "adwaita-dark";
      };
    };
  };
}
