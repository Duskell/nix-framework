# https://github.com/medusalix/xone
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.drivers.xone;
in
{

  options.nixos-framework.drivers.xone = {
    enable = lib.mkEnableOption "install Xbox controller drivers";

    resetAdaptersAfterBoot = lib.mkEnableOption "reset USB Xbox controller adapters after boot";
  };

  config = mkIf cfg.enable (mkMerge [

    {
      # Xbox One Wireless Adapter
      hardware.xone.enable = true;
    }

    # Workaround to fix the adapter not working without being
    # unplugged and plugged back in.
    (mkIf cfg.resetAdaptersAfterBoot {
      systemd.timers."reset-xbox-wireless-adapter" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          Unit = "reset-xbox-wireless-adapter";
        };
      };

      systemd.services."reset-xbox-wireless-adapter" = {
        script = ''
          set -euo pipefail
          ${pkgs.usbutils}/bin/usbreset "045e:02e6"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    })

  ]);
}