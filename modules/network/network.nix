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
      default = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
      description = "List of DNS servers to use";
    };

    dnssecMode = mkOption {
      type = types.enum [ "false" "allow-downgrade" "true" ];
      default = "allow-downgrade";
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
      description = "Enable packet forwarding";
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
  };

  config = mkMerge [

    {
      networking.networkmanager.enable = true;
    }

    (lib.mkIf cfg.dns {
      services.resolved = {
        enable = true;
        dnssec = cfg.dnssecMode;
        dnsovertls = "opportunistic";
        fallbackDNS = [
          "1.1.1.2"
          "1.0.0.2"
          "2606:4700:4700::1112"
          "2606:4700:4700::1002"
        ];
        domains = [ "~." ]; 
      };

      networking.nameservers = cfg.dnsServers;
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

    {
      networking.enableIPv6 = cfg.ipv6.enable;
    }

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

    {
      boot.kernel.sysctl = {
        "net.netfilter.nf_conntrack_max" = cfg.connectionTracking.maxConnections;
        "net.ipv4.netfilter.ip_conntrack_tcp_timeout_established" = cfg.connectionTracking.tcpTimeout;
        "net.ipv4.tcp_fastopen" = 3; # TODO make this configurable
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.rmem_max" = 16777216; # TODO make this configurable
        "net.core.wmem_max" = 16777216; # TODO make this configurable
      };
    }
  ];
}