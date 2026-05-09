
# Wiki:     https://wiki.nixos.org/wiki/Bottles
# Homepage: https://usebottles.com/
{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.nixos-framework.programs.bottles;
in
{
  options.nixos-framework.programs.bottles = {
    enable = lib.mkEnableOption "install Bottles";
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
      environment.systemPackages = with pkgs; [ (bottles.override { removeWarningPopup = true; }) ];
    }

  ]);
}