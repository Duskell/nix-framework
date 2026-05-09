{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.nixos-framework.boot.performance;
in
{
  options.nixos-framework.boot.performance = {
    enable = mkEnableOption "system performance tuning";
    
    disableTHP = mkEnableOption "disable Transparent HugePages" // {
      default = true;
    };
    
    tcpFastOpen = mkEnableOption "enable TCP Fast Open for lower network latency" // {
      default = true;
    };
    
    enableBBR = mkEnableOption "enable BBR TCP congestion control algorithm" // {
      default = true;
    };

    swappiness = mkOption {
      type = types.int;
      default = 10;
      description = "how aggressively the kernel swaps memory to disk (0-100). Lower is better for desktops.";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    {
      boot.kernel.sysctl = {
        "vm.swappiness" = cfg.swappiness;
      };
    }

    (mkIf cfg.disableTHP {
      boot.kernelParams = [ "transparent_hugepage=never" ];
    })

    (mkIf cfg.tcpFastOpen {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_fastopen" = 3;
      };
    })

    (mkIf cfg.enableBBR {
      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq"; 
      };
    })

  ]);
}