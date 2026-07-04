{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.framework.programs.nixvim;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.programs.nixvim = {
    enable = mkEnableOption "Whether to enable nixvim";

    default =
      mkEnableOption "Whether to set neovim as the default editor"
      // {
        default = true;
      };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = ''
        Arbitrary options to pass directly to Nixvim
      '';
    };

    colorScheme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The colorscheme to use
      '';
    };
  };

  config = mkIf cfg.enable {
    framework.defaults.editor = mkIf cfg.default {
      cmd = "nvim";
      desktop = "nvim";
    };

    home-manager.users.${primaryUser} = {
      imports = [inputs.nixvim.homeModules.nixvim];

      programs.nixvim = lib.mkMerge [
        cfg.settings
        {
          enable = true;
          version.enableNixpkgsReleaseCheck = false;
          colorschemes.${cfg.colorScheme}.enable = true;
        }
      ];
    };
  };
}
