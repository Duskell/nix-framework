# https://wiki.nixos.org/wiki/Printing
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  cfg = config.framework.hardware.print;
in {
  options.framework.hardware.print = {
    enable = lib.mkEnableOption "Enable printing";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Enable CUPS to print.
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        cups-filters
        gutenprint
        hplipWithPlugin
        splix
      ];

      services.ipp-usb.enable = false;

      hardware.sane.enable = true;
      hardware.sane.extraBackends = [pkgs.hplipWithPlugin];
    }
  ]);
}
