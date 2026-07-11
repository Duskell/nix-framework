{
  config,
  lib,
  pkgs,
  framework,
  ...
} @ inputs: let
  inherit (lib) mkIf mkMerge mkOption;
  inherit (framework.lib) desktops;
  cfg = config.framework.desktop.ly;
in {
  options.framework.desktop.ly = {
    package = mkOption {
      type = lib.types.package;
      default = pkgs.ly;
      description = "the ly package to use";
    };

    options = mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "extra settings merged in and overwriting defaults in config.ini.";
    };
  };

  config = let
    chosenEnv = desktops.environmentByName config.framework.desktop.environment;
    wayland =
      if chosenEnv != null
      then desktops.usesWayland chosenEnv
      else false;
  in
    mkIf (config.framework.desktop.enable && chosenEnv.dm == "ly") {
      services.displayManager.ly.enable = true;
      services.displayManager.ly.settings =
        {
          save = true;
          load = true;
          animation = "dur_file";
          dur_file_path = framework + "/assets/ly-animations/blackhole-smooth-240x67.dur";
          full_color = true;
        }
        // cfg.options;
      services.displayManager.ly.package = cfg.package;
      services.displayManager.ly.x11Support = !wayland;
    };
}
