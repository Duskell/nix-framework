{ config, lib, ... }:
let
  inherit (lib) mkMerge;
  cfg = config.nixos-framework.network.firewall;
in
{
  options.nixos-framework.network.firewall = {
    enable = lib.mkEnableOption "enable firewall" // {
      default = true;
    };
    
    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "List of open TCP ports.";
    };

    allowedUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "List of open UDP ports.";
    };
  };

  config = mkMerge [
    (lib.mkIf cfg.enable {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ] ++ cfg.allowedTCPPorts;
      };
    })
  ];
}