{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.hardware.logitech;
in
{
  options.framework.hardware.logitech = {
    enable = lib.mkEnableOption "enable Logitech hardware support";

    keyboard = lib.mkEnableOption "enable Logitech keyboard support" // {
      default = true;
    };

    mouse = lib.mkEnableOption "enable Logitech mouse support" // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # Use ratbagd + piper to configure Logitech Gaming peripheral macros.
    # Use openrgb to configure LEDs.
    (mkIf (cfg.keyboard || cfg.mouse) {
      services.ratbagd.enable = true;
      services.hardware.openrgb.enable = true;
      environment.systemPackages = with pkgs; [
        piper
      ];
    })

  ]);
}