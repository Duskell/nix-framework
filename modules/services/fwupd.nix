{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.services.fwupd;
in
{
  options.framework.services.fwupd = {
    enable = lib.mkEnableOption "enable fwupd";
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
      services.fwupd.enable = true;
      environment.systemPackages = with pkgs; [
        fwupd
      ];
    }

  ]);
}