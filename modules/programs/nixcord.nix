{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.programs.nixcord;
  primaryUser = config.nixos-framework.core.primaryUser;
in
{
  options.nixos-framework.programs.nixcord = {
    enable = lib.mkEnableOption "enable nixcord";

    vesktop.enable = lib.mkEnableOption "enable vesktop" // {
      default = true;
    };
    dorion.enable = lib.mkEnableOption "enable dorion";
    legcord.enable = lib.mkEnableOption "enable legcord";
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
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
    }

  ]);
}