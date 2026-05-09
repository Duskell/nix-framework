{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.core;
in
{
  options.nixos-framework.core = {

  };

  config = mkMerge [
    {
      time.timeZone = "Europe/Budapest";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_TIME = "hu_HU.UTF-8";
        LC_NUMERIC = "hu_HU.UTF-8";
        LC_MONETARY = "hu_HU.UTF-8";
        LC_MEASUREMENT = "hu_HU.UTF-8";
      };

      # Configure console keymap
      console.keyMap = "hu";

      hardware.enableAllFirmware = true;

      programs.mtr.enable = true;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      programs.git = {
        enable = true;
        config = {
          user.name = "Duskell";
          user.email = "duskell@proton.me";
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