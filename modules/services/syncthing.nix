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
  cfg = config.nixos-framework.services.syncthing;
in
{
  options.nixos-framework.services.syncthing = {
    enable = lib.mkEnableOption "enable Syncthing";
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };
    }

  ]);
}