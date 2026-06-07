{
  config,
  lib,
  pkgs,
  inputs,
  # framework,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkDefault
    optional
    types
    ;
  # inherit (framework.lib) desktops;
  cfg = config.framework.desktop.hyprland;
  desktop = config.framework.desktop;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.desktop.hyprland = {
    package = mkOption {
      type = types.package;
      default = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      description = "The hyprland package to use.";
    };

    portalPackage = mkOption {
      type = types.package;
      default = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      description = "The hyprland portal package to use";
    };

    wallpaper = mkOption {
      type = types.path;
      default = "/home/${primaryUser}/background.png";
      description = "Wallpaper to set. Only use if stylix is disabled.";
    };

    modKey = mkOption {
      type = types.str;
      default = "SUPER";
      description = "The modifier key to use for i3 keybindings (e.g., Mod4 for the Super/Windows key).";
    };

    #startup = mkOption {
    #  type = types.listOf types.attrs;
    #  default = [];
    #  description = "The commands to run at startup";
    #};
  };

  config = mkIf (desktop.enable && desktop.environment == "hyprland") {
    programs.hyprland = {
      enable = true;
      package = cfg.package;
      portalPackage = cfg.portalPackage;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      autorandr
      arandr
      brightnessctl
      feh
    ];

    home.users.${primaryUser} = {
      wayland.windowManager.hyprland = {
        enable = true;
        package = cfg.package;
        portalPackage = cfg.portalPackage;
        systemd.enable = false;

        settings = {
          "$mod" = cfg.modKey;
          bind =
            [
              "$mod, B, exec, firefox"
            ]
            ++ optional config.framework.grimblast.enable ", Print, exec, grimblast copy area"
            ++ (
              builtins.concatLists (builtins.genList (
                  i: let
                    ws = i + 1;
                  in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                  ]
                )
                10)
            );
        };
      };
    };

    framework = {
      programs = {
        dolphin = {
          enable = mkDefault true;
        };
        vicinae = {
          enable = mkDefault true;
        };
      };
      services = {
        flameshot = {
          enable = mkDefault true;
        };
        polybar = {
          enable = mkDefault true;
        };
        picom = {
          enable = mkDefault true;
        };
        dunst = {
          enable = mkDefault true;
        };
        redshift = {
          enable = mkDefault true;
        };
      };
    };
  };
}
