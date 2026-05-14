{ config, lib, ... }:
let
  inherit (lib) mkMerge mkEnableOption mkOption types;
  cfg = config.framework.network;
in
{
  options.framework.network = {
    dns = mkEnableOption "enable DNS with systemd-resolved";
    
    dnsServers = mkOption {
      type = types.listOf types.str;
      default = [ "8.8.8.8" "8.8.4.4" ];
      description = "List of DNS servers to use (requires dns = true)";
    };

    dnssecMode = mkOption {
      type = types.enum [ "no" "allow-downgrade" "yes" ];
      default = "yes";
      description = "DNSSEC validation mode";
    };

    mdns = mkEnableOption "enable mDNS/Avahi for local network discovery" // {
      default = true;
    };

    randomMacAddress = mkEnableOption "enable MAC address randomization for Wi-Fi";

    ipv6.enable = mkEnableOption "enable IPv6" // {
      default = true;
    };

    forwarding = mkOption {
      type = types.enum [ "none" "ipv4" "ipv6" "both" ];
      default = "none";
      description = "Enable packet forwarding (useful for routers/VPNs)";
    };

    connectionTracking = mkOption {
      type = types.submodule {
        options = {
          maxConnections = mkOption {
            type = types.int;
            default = 262144;
            description = "Maximum number of tracked connections";
          };
          tcpTimeout = mkOption {
            type = types.int;
            default = 432000;
            description = "TCP connection timeout in seconds";
          };
        };
      };
      default = {};
      description = "Netfilter connection tracking settings";
    };

    mtu = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Global MTU size (leave null for automatic detection)";
    };
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
        dnssec = cfg.dnssecMode;
        dnsovertls = "opportunistic";
        fallbackDns = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
      };

      # Set custom DNS servers if not using defaults
      networking.nameservers = 
        if cfg.dnsServers != [ "8.8.8.8" "8.8.4.4" ] 
        then cfg.dnsServers 
        else [ ];

      networking.networkmanager.dns = "systemd-resolved";
    })

    (lib.mkIf cfg.mdns {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    })

    (lib.mkIf cfg.randomMacAddress {
      networking.networkmanager.wifi.macAddress = "random";
    })

    # IPv6 configuration
    {
      networking.enableIPv6 = cfg.ipv6.enable;
    }

    # IP forwarding for routing/VPN use
    (lib.mkIf (cfg.forwarding != "none") (
      let
        ipv4 = cfg.forwarding == "ipv4" || cfg.forwarding == "both";
        ipv6 = cfg.forwarding == "ipv6" || cfg.forwarding == "both";
      in
      {
        boot.kernel.sysctl = lib.mkMerge [
          (lib.mkIf ipv4 { "net.ipv4.ip_forward" = 1; })
          (lib.mkIf ipv6 { "net.ipv6.conf.all.forwarding" = 1; })
        ];
      }
    ))

    # Connection tracking settings
    {
      boot.kernel.sysctl = {
        "net.netfilter.nf_conntrack_max" = cfg.connectionTracking.maxConnections;
        "net.ipv4.netfilter.ip_conntrack_tcp_timeout_established" = cfg.connectionTracking.tcpTimeout;
      };
    }

    # MTU configuration (if specified)
    (lib.mkIf (cfg.mtu != null) {
      networking.interfaces = lib.mapAttrs (_: v: { mtu = cfg.mtu; }) config.networking.interfaces;
    })
  ];
}