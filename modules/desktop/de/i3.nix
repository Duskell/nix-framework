{
  config,
  lib,
  pkgs,
  # framework,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkDefault
    types
    ;
  # inherit (framework.lib) desktops;
  cfg = config.framework.desktop.i3;
  desktop = config.framework.desktop;
  primaryUser = config.framework.primaryUser;
in {
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

    wallpaperMode = mkOption {
      type = types.enum ["center" "scale" "fill" "max" "tile"];
      default = "scale";
      description = "Had no better solution to feh modes. Applies even with stylix.";
    };

    modKey = mkOption {
      type = types.str;
      default = "Mod4";
      description = "The modifier key to use for i3 keybindings (e.g., Mod4 for the Super/Windows key).";
    };

    startup = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "The commands to run at startup";
    };

    keybinds = mkOption {
      type = types.attrs;
      default = {};
      description = "Custom keybinds that overwrite the i3 defaults. $MOD is replaced with the modKey set.";
    };
  };

  config = mkIf (desktop.enable && desktop.environment == "i3") {
    services.xserver.windowManager.i3 = {
      enable = true;
      package = cfg.package;
      extraPackages = with pkgs; [i3lock-color];
    };

    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-gtk
      autorandr
      arandr
      brightnessctl
      feh
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      config.common = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
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
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    home-manager.users.${primaryUser} = {
      home.file.".xprofile".text = ''
        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        elif [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
          . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
        fi
      '';

      xsession.windowManager.i3 = {
        enable = true;
        package = cfg.package;

        config = {
          modifier = cfg.modKey;
          bars = [];
          window.border = 0;
          window.titlebar = false;

          floating.border = 0;
          floating.titlebar = false;

          gaps = {
            inner = 20;
            outer = 5;
          };

          keybindings = let
            processedUserBinds =
              lib.mapAttrs' (
                name: value:
                  lib.nameValuePair
                  (builtins.replaceStrings ["$MOD"] [cfg.modKey] name)
                  (builtins.replaceStrings ["$MOD"] [cfg.modKey] value)
              )
              cfg.keybinds;
          in
            {
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+";
              "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
              "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
              "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

              "${cfg.modKey}+Return" = "exec alacritty";
              "${cfg.modKey}+space" = "exec vicinae open";
              "${cfg.modKey}+b" = "exec firefox";
              "${cfg.modKey}+Shift+x" = "exec systemctl suspend";
              "${cfg.modKey}+Shift+q" = "kill";
              "${cfg.modKey}+Shift+r" = "restart";

              #"${cfg.modKey}+h" = "focus left";
              #"${cfg.modKey}+j" = "focus down";
              #"${cfg.modKey}+k" = "focus up";
              #"${cfg.modKey}+l" = "focus right";

              "${cfg.modKey}+Shift+h" = "move left";
              "${cfg.modKey}+Shift+j" = "move down";
              "${cfg.modKey}+Shift+k" = "move up";
              "${cfg.modKey}+Shift+l" = "move right";

              "${cfg.modKey}+Shift+v" = "split v";
              "${cfg.modKey}+Shift+b" = "split h";

              "${cfg.modKey}+f" = "fullscreen toggle";

              "${cfg.modKey}+s" = "layout stacking";
              "${cfg.modKey}+w" = "layout tabbed";
              "${cfg.modKey}+e" = "layout toggle split";

              "${cfg.modKey}+Shift+space" = "floating toggle";

              "${cfg.modKey}+1" = "workspace 1";
              "${cfg.modKey}+2" = "workspace 2";
              "${cfg.modKey}+3" = "workspace 3";
              "${cfg.modKey}+4" = "workspace 4";
              "${cfg.modKey}+5" = "workspace 5";
              "${cfg.modKey}+6" = "workspace 6";
              "${cfg.modKey}+7" = "workspace 7";
              "${cfg.modKey}+8" = "workspace 8";
              "${cfg.modKey}+9" = "workspace 9";
              "${cfg.modKey}+0" = "workspace 10";

              "${cfg.modKey}+Shift+1" = "move container to workspace 1";
              "${cfg.modKey}+Shift+2" = "move container to workspace 2";
              "${cfg.modKey}+Shift+3" = "move container to workspace 3";
              "${cfg.modKey}+Shift+4" = "move container to workspace 4";
              "${cfg.modKey}+Shift+5" = "move container to workspace 5";
              "${cfg.modKey}+Shift+6" = "move container to workspace 6";
              "${cfg.modKey}+Shift+7" = "move container to workspace 7";
              "${cfg.modKey}+Shift+8" = "move container to workspace 8";
              "${cfg.modKey}+Shift+9" = "move container to workspace 9";
              "${cfg.modKey}+Shift+0" = "move container to workspace 10";

              "Print" = "exec flameshot gui";

              "${cfg.modKey}+l" = "exec i3lock-color";
              "${cfg.modKey}+m" = "exec pear-desktop";
            }
            // processedUserBinds;

          startup =
            [
              (mkIf config.framework.programs.autorandr.enable {
                command = "autorandr --change built-in && sleep 1 && autorandr --change";
                always = false;
                notification = false;
              })
              (mkIf config.framework.programs.vicinae.enable {
                command = "vicinae server";
                always = false;
                notification = false;
              })
              {
                command = "systemctl --user import-environment DISPLAY XAUTHORITY";
                always = false;
                notification = false;
              }
              {
                command = "systemctl --user start graphical-session.target";
                always = false;
                notification = false;
              }
              {
                command = "systemctl --user restart polybar.service";
                always = false;
                notification = false;
              }
              {
                command = "feh --bg-${cfg.wallpaperMode} ${
                  if config.framework.programs.stylix.enable
                  then "${config.framework.programs.stylix.wallpaper}"
                  else cfg.wallpaper
                }";
                always = true;
                notification = false;
              }
            ]
            ++ cfg.startup;
        };
      };
    };
  };
}
