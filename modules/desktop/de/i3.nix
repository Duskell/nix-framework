{
  config,
  lib,
  pkgs,
  framework,
  ...
}@inputs:
let
  inherit (lib)
    mkIf
    mkOption
    mkDefault
    types;
  inherit (framework.lib) desktops;
  cfg = config.framework.desktop.i3;
  desktop = config.framework.desktop;
  primaryUser = config.framework.primaryUser;
in
{
  options.framework.desktop.i3 = {
    package = mkOption {
      type = types.package;
      default = pkgs.i3;
      description = "The i3 package to use.";
    };

    wallpaper = mkOption {
      type = types.path;
      default = "/home/${primaryUser}/background.png";
      description = "Wallpaper to set. Only use if stylix is disabled.";
    };

    modKey = mkOption {
      type = types.str;
      default = "Mod4";
      description = "The modifier key to use for i3 keybindings (e.g., Mod4 for the Super/Windows key).";
    };
  };

  config = mkIf (desktop.enable && desktop.environment == "i3") {
    services.xserver.windowManager.i3 = {
      enable = true;
      package = cfg.package;
      extraPackages = with pkgs; [ i3lock-color ];
    };

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gtk
      autorandr
      brightnessctl
      feh
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
    
    framework = {
      programs = {
        thunar = {
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

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    
    home-manager.users.${primaryUser} = {
      xsession.windowManager.i3 = {
        enable = true;
        package = cfg.package;
        
        config = {
          modifier = cfg.modKey;
          bars = [ ];
          window.border = 0;

          gaps = {
            inner = 15;
            outer = 5;
          };

          keybindings = lib.mkOptionDefault {
            "XF86AudioMute"         = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioLowerVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-";
            "XF86AudioRaiseVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+";
            "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
            "XF86MonBrightnessUp"   = "exec brightnessctl set 4%+";
            
            "${cfg.modKey}+Return"    = "exec alacritty";
            "${cfg.modKey}+Space"     = "exec vicinae"; 
            "${cfg.modKey}+b"         = "exec firefox";
            "${cfg.modKey}+Shift+x"   = "exec systemctl suspend";
          };

          startup = [
            {
              command = "systemctl --user restart polybar.service";
              always = true;
              notification = false;
            }
            {
              # Ensure ~/background.png exists, or use an absolute path
              command = "feh --bg-scale ${if config.framework.programs.stylix.enable then "${config.framework.programs.stylix.backgroundImage}" else cfg.wallpaper}";
              always = true;
              notification = false;
            }
          ];
        };
      };
    };
  };
}