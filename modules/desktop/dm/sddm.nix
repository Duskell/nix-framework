{
  config,
  lib,
  pkgs,
  framework,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (framework.lib) desktops;
  cfg = config.framework.desktop.sddm;
in
{
  # some options directly from the sddm package
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/display-managers/sddm.nix
  options.framework.desktop.sddm = {
    wayland.compositor = mkOption {
      type = types.enum [ "kwim" "weston" ];
      default = "weston";
      description = ''
        The compositor to use: kwim, weston
      '';
    };

    settings = mkOption {
      type = types.anything;
      default = { };
      example = {
        Autologin = {
          User = "john";
          Session = "plasma.desktop";
        };
      };
      description = ''
        Extra settings merged in and overwriting defaults in sddm.conf.
      '';
    };

    theme = mkOption {
      type = types.str;
      default = "";
      example = lib.literalExpression "\"\${pkgs.where-is-my-sddm-theme.override { variants = [ \"qt5\" ]; }}/share/sddm/themes/where_is_my_sddm_theme_qt5\"";
      description = ''
        Greeter theme to use.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      defaultText = "[]";
      description = ''
        Extra Qt plugins / QML libraries to add to the environment.
      '';
    };

  };

  config = let
    chosenEnv = desktops.environmentByName config.framework.desktop.environment;
    wayland = if chosenEnv != null then chosenEnv.wayland else false;
  in mkIf (config.framework.desktop.enable && chosenEnv.dm == "sddm") {
    services.displayManager.sddm.enable = true;

    services.displayManager.sddm.wayland.enable = wayland; # Wayland support is experimental still
    services.displayManager.sddm.wayland.compositor = cfg.wayland.compositor;

    services.displayManager.sddm.settings = cfg.settings;

    services.displayManager.sddm.extraPackages = cfg.extraPackages;

    services.displayManager.sddm.theme = cfg.theme;
  };
}