# https://nixos.wiki/wiki/Bluetooth
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.framework.hardware.cpu;
in
{
  options.framework.hardware.cpu = {
    enable = mkEnableOption ''
      Whether to enable cpu settings
    '' //  { default = true; };

    intel.enable = mkEnable ''
      If u have an intel cpu. Also enable some intel specific boot options
    '';
    intel.updateMicrocode = mkEnableOption ''
      Whether to enable the updating of microcode
    '';
  };

  config = mkIf cfg.enable {
    hardware.cpu = {
      intel.updateMicrocode = cfg.intel.updateMicrocode;
    };
  };
}