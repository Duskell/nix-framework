# https://nixos.wiki/wiki/Bluetooth
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.framework.hardware.bluetooth;
in
{
  options.framework.hardware.bluetooth = {
    enable = lib.mkEnableOption "enable Bluetooth stack";
  };

  config = mkIf cfg.enable (mkMerge [

    # Enable Bluetooth support.
    {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    }

  ]);
}