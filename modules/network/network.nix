{ config, lib, ... }:
let
  inherit (lib) mkMerge;
  cfg = config.nixos-framework.network;
in
{
  options.nixos-framework.network = {
    dns = lib.mkEnableOption "enable DNS with systemd-resolved";
    mdns = lib.mkEnableOption "enable mDNS/Avahi for local network discovery" // {
      default = true;
    };
    randomMacAddress = lib.mkEnableOption "enable MAC address randomization for Wi-Fi";
  };

  config = mkMerge [

    # Enable networking.
    {
      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Pick only one of the below networking options.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
      networking.networkmanager.enable = true;
    }

    (lib.mkIf cfg.dns {
      services.resolved = {
        enable = true;
        dnssec = "allow-downgrade";
        dnsovertls = "opportunistic"; # or "yes" to force it
        fallbackDns = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
      };

      networking.networkmanager.dns = "systemd-resolved";
    })

    (lib.mkIf cfg.mdns {
      services.avahi = {
        enable = true;
        nssmdns4 = true; # Allows software to use Avahi to resolve .local domains
        openFirewall = true;
      };
    })

    (lib.mkIf cfg.randomMacAddress {
      networking.networkmanager.wifi.macAddress = "random";
    })

    (lib.mkIf cfg.tailscale.enable {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = cfg.tailscale.routingFeatures;
        extraUpFlags = cfg.tailscale.flags;
        
        authKeyFile = config.age.secrets.tailscale-key.path; 
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ]; 
    })
  ];
}