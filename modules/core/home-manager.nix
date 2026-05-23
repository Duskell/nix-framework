{
  inputs,
  config,
  lib,
  framework,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption;
  cfg = config.framework.core.hm;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.framework.core.hm = {
    enable = mkEnableOption "Home Manager configuration" // {default = true;};

    backupExtension = mkOption {
      type = types.str;
      default = "hm-backup";
    };

    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      description = "List of Home Manager modules to load for the primary user.";
    };

    silentNews = mkEnableOption "Silence Home Manager news" // {default = true;};
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = cfg.backupExtension;

      extraSpecialArgs = {
        inherit framework inputs;
        sysConfig = config;
      };

      users.${config.framework.primaryUser} = {
        imports = cfg.modules;

        home.stateVersion = config.system.stateVersion;

        news.display = mkIf cfg.silentNews "silent";

        xsession.target.enable = true;

        programs.home-manager.enable = true;
      };
    };
  };
}

