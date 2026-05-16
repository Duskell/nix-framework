# Wiki:     https://wiki.nixos.org/wiki/Bottles
# Homepage: https://usebottles.com/
{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.bottles;
in
{
  options.framework.programs.bottles = {
    enable = lib.mkEnableOption "install Bottles";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ (bottles.override { removeWarningPopup = true; }) ];
  };
}