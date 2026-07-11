{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption mkEnableOption types;
  cfg = config.framework.services.polybar;
in {
  options.framework.services.polybar = {
    enable = mkEnableOption "enable Polybar";

    theme = mkOption {
      type = types.enum ["lines" "floating" "custom"];
      default = "floating";
      description = "The built-in theme to use, if theme is set with direct config then set it to custom";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "These are written directly to the config";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      services.polybar = {
        enable = true;

        package = pkgs.polybar;

        script = "polybar -q -r top & polybar -q -r bottom &";

        config =
          if cfg.theme == "custom"
          then cfg.settings
          else (import ./themes/${cfg.theme}.nix {inherit pkgs framework;}) // cfg.settings;
      };
    };
  };
}
