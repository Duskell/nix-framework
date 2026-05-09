{ config, lib, nixos-framework, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.nixos-framework.hardware.gamepads;
in
{
  options.nixos-framework.hardware.gamepads = {
    enable = lib.mkEnableOption "enable gamepad support";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Xbox One Wireless Adapter
      nixos-framework.drivers.xone.enable = mkDefault true;
    }
  ]);
}