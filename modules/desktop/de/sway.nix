{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkDefault
    types
    nameValuePair
    mapAttrs'
    ;

  cfg = config.framework.desktop.sway;
  desktop = config.framework.desktop;
  primaryUser = config.framework.primaryUser;

  fwDefaults = config.framework.defaults;
in {
  options.framework.desktop.sway = {
    package = mkOption {
      type = types.package;
      default = pkgs.swayfx;
      description = "The sway package to use.";
    };

    defaultWallpaper = mkOption {
      type = types.str;
      default = "/home/${primaryUser}/.background.png";
      description = "Wallpaper to set. Ignored if stylix is enabled.";
    };

    modKey = mkOption {
      type = types.str;
      default = "Mod4";
      description = "The modifier key for sway (e.g., Mod4 for Super/Windows).";
    };

    launcher = mkOption {
      type = types.str;
      default = "vicinae open";
      description = "Default application launcher command.";
    };

    lockCommand = mkOption {
      type = types.str;
      default = "swaylock";
      description = "Command to execute for locking the screen.";
    };

    gaps = {
      inner = mkOption {
        type = types.int;
        default = 20;
        description = "Inner gaps size.";
      };
      outer = mkOption {
        type = types.int;
        default = 5;
        description = "Outer gaps size.";
      };
    };

    effects = {
      enableBlur = mkOption {
        type = types.bool;
        default = true;
      };

      blurRadius = mkOption {
        type = types.int;
        default = 5;
      };

      blurPasses = mkOption {
        type = types.int;
        default = 2;
      };

      cornerRadius = mkOption {
        type = types.int;
        default = 10;
      };

      enableShadows = mkOption {
        type = types.bool;
        default = true;
      };

      enableAnimations = mkOption {
        type = types.bool;
        default = true;
      };

      inactiveDim = mkOption {
        type = types.float;
        default = 0.05;
      };
    };

    floating = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Floating window classes";
    };

    enableDefaultIntegrations = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically enable framework default companion services when sway is active.";
    };

    startup = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Custom startup commands to append to the framework defaults.";
    };

    keybinds = mkOption {
      type = types.attrs;
      default = {};
      description = "Custom keybinds overriding defaults. '$MOD' is replaced with the configured modKey.";
    };

    modes = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      default = {};
      description = "Custom sway modes.";
    };
  };

  config = mkIf (desktop.enable && desktop.environment == "sway") {
    programs.sway = {
      enable = true;
      package = cfg.package;
      wrapperFeatures.gtk = true;
    };

    services.gnome.gnome-keyring.enable = true;

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

    framework = mkIf cfg.enableDefaultIntegrations {
      programs = {
        vicinae.enable = mkDefault true;
      };
      services = {
        dunst.enable = mkDefault true;
      };
    };

    security.polkit.enable = true;

    # systemd.user.services.polkit-gnome-authentication-agent-1 = {
    #   description = "polkit-gnome-authentication-agent-1";
    #   wantedBy = ["graphical-session.target"];
    #   wants = ["graphical-session.target"];
    #   after = ["graphical-session.target"];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #     Restart = "on-failure";
    #     RestartSec = 1;
    #     TimeoutStopSec = 10;
    #   };
    # };

    systemd.user.services.low-battery-warning = {
      wantedBy = ["default.target"];

      serviceConfig = {
        ExecStart = "${pkgs.low-battery-warning}/bin/low-battery-warning";
        Restart = "always";
      };
    };

    home-manager.users.${primaryUser} = {
      services.awww.enable = true;

      home.packages = with pkgs; [
        sway-contrib.grimshot
      ];

      wayland.windowManager.sway = {
        package = cfg.package;
        enable = true;
        checkConfig = false;
        config = {
          modifier = cfg.modKey;
          bars = [];

          window = {
            border = 0;
            titlebar = false;
          };

          floating = {
            border = 0;
            titlebar = false;
            criteria = cfg.floating;
          };

          gaps = {
            inner = cfg.gaps.inner;
            outer = cfg.gaps.outer;
          };

          terminal = fwDefaults.terminal.cmd;

          keybindings = let
            processedUserBinds =
              mapAttrs' (
                name: value:
                  nameValuePair
                  (builtins.replaceStrings ["$MOD"] [cfg.modKey] name)
                  (builtins.replaceStrings ["$MOD"] [cfg.modKey] value)
              )
              cfg.keybinds;

            staticBinds = {
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+";
              "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
              "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
              "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

              "${cfg.modKey}+l" = "exec ${cfg.lockCommand}";
              "Print" = "exec grimshot save area";
              "${cfg.modKey}+Print" = "exec grimshot save output";

              "${cfg.modKey}+Shift+q" = "kill";
              "${cfg.modKey}+Shift+r" = "exec restart";

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
            };
            dynamicBinds =
              (lib.optionalAttrs (fwDefaults.terminal != null) {"${cfg.modKey}+Return" = "exec ${fwDefaults.terminal.cmd}";})
              // (lib.optionalAttrs (fwDefaults.browser != null) {"${cfg.modKey}+b" = "exec ${fwDefaults.browser.cmd}";})
              // (lib.optionalAttrs (fwDefaults.launcher != null) {"${cfg.modKey}+space" = "exec ${fwDefaults.launcher.cmd}";});
          in
            staticBinds // dynamicBinds // processedUserBinds;

          startup =
            [
              {
                command = "systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS";
                always = false;
                notification = false;
              }
              # {
              #   command = "systemctl --user start graphical-session.target";
              #   always = false;
              #   notification = false;
              # }
              {
                command = "systemctl --user restart low-battery-warning.service";
                always = false;
                notification = false;
              }
              # {
              #   command = "feh --bg-${cfg.wallpaperMode} ${
              #     if config.framework.programs.stylix.enable
              #     then "${config.framework.programs.stylix.wallpaper}"
              #     else cfg.wallpaper
              #   }";
              #   always = true;
              #   notification = false;
              # }
            ]
            ++ lib.optional config.framework.programs.kanshi.enable {
              command = "systemctl --user start kanshi.service";
              always = false;
              notification = false;
            }
            ++ lib.optional config.framework.programs.vicinae.enable {
              command = "vicinae server";
              always = false;
              notification = false;
            }
            ++ cfg.startup;

          modes = cfg.modes;
        };

        extraConfig = ''
          # Animations
          ${lib.optionalString cfg.effects.enableAnimations ''

          ''}

          # Blur
          ${lib.optionalString cfg.effects.enableBlur ''
            blur enable
            blur_xray disable
            blur_passes ${toString cfg.effects.blurPasses}
            blur_radius ${toString cfg.effects.blurRadius}
            blur_noise 0.02
            blur_brightness 1.0
            blur_contrast 1.0
            blur_saturation 1.0
          ''}

          # Rounded corners
          corner_radius ${toString cfg.effects.cornerRadius}

          # Shadows
          ${lib.optionalString cfg.effects.enableShadows ''
            shadows enable
            shadows_on_csd disable
            shadow_blur_radius 15
            shadow_color #00000099
            shadow_offset 2 3
          ''}

          # Inactive window dimming
          default_dim_inactive ${toString cfg.effects.inactiveDim}
        '';
      };
    };
  };
}
