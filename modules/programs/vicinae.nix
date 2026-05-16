{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.programs.vicinae;
in
{
  options.framework.programs.vicinae = {
    enable = lib.mkEnableOption "install vicinae";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vicinae
    ];
  };
}