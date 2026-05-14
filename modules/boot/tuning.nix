{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types;
  cfg = config.framework.boot.performance;
in
{
  options.framework.boot.performance = {
    enable = mkEnableOption "system performance tuning";
    
    # Memory management
    disableTHP = mkEnableOption "disable Transparent HugePages" // {
      default = true;
    };
    
    swappiness = mkOption {
      type = types.int;
      default = 10;
      description = "How aggressively the kernel swaps memory to disk (0-100). Lower values favor memory usage.";
    };

    memoryOvercommit = mkOption {
      type = types.enum [ "never" "guess" "always" ];
      default = "guess";
      description = "Memory overcommit behavior: never (0), guess (1), always (2)";
    };

    dirtyRatio = mkOption {
      type = types.int;
      default = 10;
      description = "Percentage of memory that can be dirty before writeback (5-50)";
    };

    dirtyBackgroundRatio = mkOption {
      type = types.int;
      default = 5;
      description = "Percentage of memory that triggers asynchronous writeback (1-50)";
    };

    # Network
    tcpFastOpen = mkEnableOption "enable TCP Fast Open for lower network latency" // {
      default = true;
    };
    
    enableBBR = mkEnableOption "enable BBR TCP congestion control algorithm" // {
      default = true;
    };

    tcpWindowScaling = mkEnableOption "enable TCP window scaling for faster transfers" // {
      default = true;
    };

    tcpSack = mkEnableOption "enable TCP SACK for improved reliability" // {
      default = true;
    };

    # I/O
    ioScheduler = mkOption {
      type = types.enum [ "mq-deadline" "kyber" "bfq" "noop" "none" ];
      default = "mq-deadline";
      description = "I/O scheduler: mq-deadline (default), kyber (balanced), bfq (fair), noop (minimal)";
    };

    readahead = mkOption {
      type = types.int;
      default = 256;
      description = "Disk read-ahead in KB (128-1024 recommended)";
    };

    # CPU/Process Scheduling
    schedMigrationCost = mkOption {
      type = types.int;
      default = 500000;
      description = "CPU migration cost in nanoseconds (higher = stay on same CPU)";
    };

    # File Handles & Resources
    maxOpenFiles = mkOption {
      type = types.int;
      default = 524288;
      description = "Global maximum open file descriptors";
    };

    # Core Dump Control
    allowCoreDumps = mkEnableOption "allow core dumps for debugging" // {
      default = false;
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # Memory management
    {
      boot.kernel.sysctl = {
        "vm.swappiness" = cfg.swappiness;
        "vm.overcommit_memory" = 
          if cfg.memoryOvercommit == "never" then 0
          else if cfg.memoryOvercommit == "always" then 2
          else 1;
        "vm.dirty_ratio" = cfg.dirtyRatio;
        "vm.dirty_background_ratio" = cfg.dirtyBackgroundRatio;
        
        # Network optimizations
        "net.core.somaxconn" = 4096;
        "net.ipv4.tcp_max_syn_backlog" = 4096;
        "net.ipv4.tcp_tw_reuse" = 1;
        
        # File descriptor limit
        "fs.file-max" = cfg.maxOpenFiles;
        
        # CPU scheduling
        "kernel.sched_migration_cost_ns" = cfg.schedMigrationCost;
      };
    }

    # Transparent HugePages
    (mkIf cfg.disableTHP {
      boot.kernelParams = [ "transparent_hugepage=never" ];
    })

    # TCP Fast Open
    (mkIf cfg.tcpFastOpen {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_fastopen" = 3;
      };
    })

    # BBR Congestion Control
    (mkIf cfg.enableBBR {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
      };
    })

    # TCP Window Scaling
    (mkIf cfg.tcpWindowScaling {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_window_scaling" = 1;
      };
    })

    # TCP SACK
    (mkIf cfg.tcpSack {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_sack" = 1;
      };
    })

    # I/O Scheduler (for hdd-s)
    {
      # NVMe drives ignore these settings
      boot.kernel.sysctl = {
        "vm.page-cluster" = 3;
        "vm.read_ahead_kb" = cfg.readahead;
      };
    }

    # Core dumps
    (mkIf (!cfg.allowCoreDumps) {
      boot.kernel.sysctl = {
        "kernel.core_uses_pid" = 0;
        "fs.suid_dumpable" = 0;
      };
    })

  ]);
}