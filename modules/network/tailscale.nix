{ config, lib, ... }:
let
  inherit (lib) mkMerge;
  cfg = config.framework.network.tailscale;
in
{
  options.framework.network.tailscale = {
    enable = lib.mkEnableOption "enable Tailscale";

    routingFeatures = lib.mkOption {
      type = lib.types.enum [ "none" "client" "server" "both" ];
      default = "client";
      description = "Routing features to enable for the node";
    };

    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "--ssh" ];
      description = "List of flags to pass to tailscale up";
    };
  };

  config = mkMerge [
    (lib.mkIf cfg.enable {
      framework.core.secrets.items."tailscale-key" = {};
        
      services.tailscale = {
        enable = true;
        useRoutingFeatures = cfg.routingFeatures;
        extraUpFlags = cfg.flags;
        
        authKeyFile = config.framework.core.secrets.items."tailscale-key".path; 
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ]; 
    })
  ];
}