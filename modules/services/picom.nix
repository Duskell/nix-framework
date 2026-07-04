# https://nix-community.github.io/home-manager/options/home-manager/services/picom.html
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    literalExpression
    ;

  cfg = config.framework.services.picom;
in {
  options.framework.services.picom = {
    enable = mkEnableOption "enable picom, a high-performance compositor for X11";

    backend = mkOption {
      type = types.enum ["egl" "glx" "xrender" "xr_glx_hybrid"];
      default = "glx";
      description = "Backend to use for rendering.";
    };

    vSync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable vertical synchronization to mitigate screen tearing.";
    };

    # --- Fading ---
    fade = mkOption {
      type = types.bool;
      default = true;
      description = "Fade windows in and out during state changes.";
    };

    fadeDelta = mkOption {
      type = types.ints.positive;
      default = 5;
      description = "Time between fade animation steps in milliseconds.";
    };

    fadeSteps = mkOption {
      type = types.listOf types.float;
      default = [0.09 0.09];
      description = "Opacity change per fade step (in and out).";
    };

    fadeExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Windows matching these conditions will skip fading.";
    };

    # --- Shadows ---
    shadow = mkOption {
      type = types.bool;
      default = true;
      description = "Draw drop shadows under windows.";
    };

    shadowOffsets = mkOption {
      type = types.listOf types.int;
      default = [(-7) (-7)];
      description = "Horizontal and vertical offset for shadows in pixels.";
    };

    shadowOpacity = mkOption {
      type = types.numbers.between 0 1;
      default = 0.7;
      description = "Global opacity floor for drop shadows.";
    };

    shadowExclude = mkOption {
      type = types.listOf types.str;
      default = [
        "window_type *= 'normal' && ! name ~= ''"
        "class_g = 'Polybar'"
        "name = 'Polybar'"
        "window_type = 'dock'"
        "window_type = 'dnd'"
      ];
      description = "Window rules excluded from drawing shadows.";
    };

    # --- Opacity ---
    activeOpacity = mkOption {
      type = types.numbers.between 0 1;
      default = 1.0;
      description = "Opacity level for focused windows.";
    };

    inactiveOpacity = mkOption {
      type = types.numbers.between 0 1;
      default = 1.0;
      description = "Opacity level for unfocused/inactive windows.";
    };

    menuOpacity = mkOption {
      type = types.numbers.between 0 1;
      default = 0.8;
      description = "Default opacity applied to context menus and popups.";
    };

    opacityRules = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Rules controlling window opacity in the format 'PERCENT:PATTERN'.";
    };

    # --- Structural Settings & Escape Hatches ---
    settings = mkOption {
      type = types.attrsOf types.deferredAttribute;
      default = {
        corner-radius = 15;

        blur-method = "dual_kawase";
        blur-strength = 5;

        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
        ];

        shadow-radius = 7;
        detect-client-opacity = true;
        detect-rounded-corners = true;
        detect-transient = true;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
      };
      example = literalExpression ''
        {
          blur = {
            method = "gaussian";
            size = 10;
          };
        }
      '';
      description = "Raw downstream picom.settings attributes. Merged directly with options.";
    };
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      inherit
        (cfg)
        backend
        vSync
        fade
        fadeDelta
        fadeSteps
        fadeExclude
        shadow
        shadowOffsets
        shadowOpacity
        shadowExclude
        activeOpacity
        inactiveOpacity
        menuOpacity
        opacityRules
        settings
        ;
    };
  };
}
