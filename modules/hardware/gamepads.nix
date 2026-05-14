{ config, lib, framework, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.hardware.gamepads;
in
{
  options.framework.hardware.gamepads = {
    enable = lib.mkEnableOption "enable gamepad support";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Xbox One Wireless Adapter
      framework.drivers.xone.enable = mkDefault true;
    }
  ]);
}