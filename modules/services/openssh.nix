{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.services.ssh;
in
{
  options.nixos-framework.services.ssh = {
    enable = mkEnableOption "enable openssh server";

    passAuth = mkEnableOption "enable authentication via a password";
  };

  config = mkMerge [
    {
      services.openssh.enable = cfg.enable;

      services.openssh.settings.PasswordAuthentication = cfg.passAuth;
      services.openssh.settings.PermitRootLogin = "no";
    }
  ];
}