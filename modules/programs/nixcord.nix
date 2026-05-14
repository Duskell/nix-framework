{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.framework.programs.nixcord;
  primaryUser = config.framework.primaryUser;
in
{
  options.framework.programs.nixcord = {
    enable = mkEnableOption "enable nixcord";

    vesktop.enable = mkEnableOption "enable vesktop" // {
      default = true;
    };
    dorion.enable = mkEnableOption "enable dorion";
    legcord.enable = mkEnableOption "enable legcord";
  };

  config = mkIf cfg.enable {
    home-manager.users.${primaryUser} = {
      imports = [ inputs.nixcord.homeModules.nixcord ];

      programs.nixcord = {
        enable = true;
        discord.enable = false;
        discord.vencord.enable = true;

        vesktop.enable = cfg.vesktop.enable;
        dorion.enable = cfg.dorion.enable;
        legcord.enable = cfg.legcord.enable;

        config = {
          plugins = {
            betterFolders.enable = true;
            betterRoleContext.enable = true;
            crashHandler.enable = true;
            memberCount.enable = true;
            mentionAvatars.enable = true;
            messageLatency.enable = true;
            showHiddenThings.enable = true;
            showMeYourName.enable = true;
            webContextMenus.enable = true;
            webKeybinds.enable = true;
            webScreenShareFixes.enable = true;
            alwaysAnimate.enable = true;
          };
        };

        extraConfig = {
          # Some extra JSON config here
          # ...
        };
      };
    };
  };
}