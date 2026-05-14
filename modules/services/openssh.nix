{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge mkEnableOption;
  cfg = config.framework.services.ssh;
in
{
  options.framework.services.ssh = {
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