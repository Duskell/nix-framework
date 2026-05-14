# Wiki:     https://wiki.nixos.org/wiki/Syncthing
# Homepage: https://syncthing.net/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.services.syncthing;
in
{
  options.framework.services.syncthing = {
    enable = lib.mkEnableOption "enable Syncthing";
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        user = config.framework.primaryUser;
        dataDir = "/home/${config.framework.primaryUser}/Sync";
        configDir = "/home/${config.framework.primaryUser}/.config/syncthing";
      };
    }

  ]);
}