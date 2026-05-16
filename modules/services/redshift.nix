# Wiki: https://wiki.nixos.org/wiki/Redshift
# Origin: https://github.com/Th0rgal/horus-nix-home/blob/master/configs/redshift.nix
{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.services.redshift;
in
{
  options.framework.services.redshift = {
    enable = lib.mkEnableOption "install redshift";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      services.redshift = {
        enable = true;
        settings.redshift = {
          brightness-day = "1";
          brightness-night = "1";
        };
        temperature = {
          day = 5500;
          night = 3000;
        };
        latitude = "47.49835";
        longitude = "19.04045";
      };
    };
  };
}