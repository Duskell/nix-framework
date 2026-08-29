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
      # Enable CUPS to print documents.
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        cups-filters
        cups-browsed
        gutenprint
        hplipWithPlugin
        hplip
        splix
      ];

      services.ipp-usb.enable = true;

      hardware.sane.enable = true;
    }
  ]);
}
