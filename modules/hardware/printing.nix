# https://wiki.nixos.org/wiki/Printing
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.hardware.print;
in
{
  options.nixos-framework.hardware.print = {
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
        hplip
        splix
      ];

      services.ipp-usb.enable = true;

      hardware.sane.enable = true;
    }

  ]);
}