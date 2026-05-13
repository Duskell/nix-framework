{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.nixos-framework.boot.plymouth;
in
{
  options.nixos-framework.boot.plymouth = {
    enable = mkEnableOption "enable plymouth" // {
      default = true;
    };

    theme = mkOption {
        type = types.str;
        default = "kuro-the-cat";
        description = "the theme plymouth will use";
    };

    themePackages = mkOption {
        type = types.listOf types.package;
        default = [ (pkgs.plymouth-themes.override { selected_themes = ["kuro-the-cat"]; })]; 
        description = "list of packages that correspond to the set themes";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot.plymouth = {
        enable = true;
        theme = cfg.theme;
        themePackages = cfg.themePackages;
      };
    }
  ]);
}