# https://wiki.nixos.org/wiki/Printing
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  cfg = config.framework.hardware.print;

  primaryUser = config.framework.primaryUser;
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
        foo2zjs
      ];

      services.ipp-usb.enable = false;

      services.udev.packages = [pkgs.hplipWithPlugin];

      hardware.sane.enable = true;
      hardware.sane.extraBackends = [pkgs.hplipWithPlugin];

      users.users.${primaryUser}.extraGroups= ["scanner" "lp"]
    }
  ]);
}
