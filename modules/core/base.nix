{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.framework.core;
in {
  options.framework.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = "The main user of the system";
  };

  options.framework.core = {
    timezone = mkOption {
      type = types.str;
      default = "Europe/Budapest";
      description = "System timezone";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale";
    };

    consoleKeyMap = mkOption {
      type = types.str;
      default = "hu";
      description = "Console keymap";
    };

    git = {
      enable =
        mkEnableOption "configure git"
        // {
          default = true;
        };

      userName = mkOption {
        type = types.str;
        default = "Duskell";
        description = "Git user name";
      };

      userEmail = mkOption {
        type = types.str;
        default = "duskell@proton.me";
        description = "Git user email";
      };
    };
  };

  config = mkMerge [
    {
      time.timeZone = cfg.timezone;

      i18n.defaultLocale = cfg.locale;
      i18n.extraLocaleSettings = {
        LC_TIME = "hu_HU.UTF-8";
        LC_NUMERIC = "hu_HU.UTF-8";
        LC_MONETARY = "hu_HU.UTF-8";
        LC_MEASUREMENT = "hu_HU.UTF-8";
      };

      # Configure console keymap
      console.keyMap = cfg.consoleKeyMap;

      hardware.enableAllFirmware = true;

      programs.mtr.enable = true;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      programs.git = mkIf cfg.git.enable {
        enable = true;
        config = {
          user.name = cfg.git.userName;
          user.email = cfg.git.userEmail;
          init.defaultBranch = "main";
          pull.rebase = true;
          color.ui = "auto";
          core.autocrlf = "input";
          fetch.parallel = "8";
          log.decorate = "auto";
          log.abbrev = "12";
          commit.gpgsign = true;
        };
      };
    }
  ];
}
