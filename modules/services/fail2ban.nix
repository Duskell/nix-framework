{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.services.fail2ban;
in
{
  options.nixos-framework.services.fail2ban = {
    enable = mkEnableOption "enable fail2ban";

    ssh.enable = mkEnableOption "enable jail for ssh";
  };

  config = mkMerge [
    {
      services.fail2ban.enable = cfg.enable;
      services.fail2ban.jails.ssh = {
        enabled = cfg.ssh.enable;
      };
    }
  ];
}