# https://nixos.wiki/wiki/Nvidia
{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.drivers.nvidia;
in
{

  options.framework.drivers.nvidia = {
    enable = lib.mkEnableOption "install NVIDIA drivers";
    package = lib.mkOption {
      default = (import ../patches/linux-nvidia-595.nix inputs);
      description = "the NVIDIA kernel packages";
    };

    useOpenKernelDrivers = lib.mkEnableOption "use open-source kernel drivers";

    powerManagement = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "enable PowerManagement";
          finegrained = lib.mkEnableOption "enable finegrained";
        };
      };
      default = {};
      description = "NVIDIA PowerManagement";
    };

    prime = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "enable Prime";
          intelBusId = lib.mkOption {
            type = lib.types.str;
            default = "PCI:0:2:0";
            description = "Make sure to use the correct Bus ID values for your system!";
          };

          nvidiaBusId = lib.mkOption {
            type = lib.types.str;
            default = "PCI:01:0:0";
            description = "Make sure to use the correct Bus ID values for your system!";
          };
        };
      };
      default = {};
      description = "NVIDIA Prime for hybrid setups";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # Enable NVIDIA GPU drivers.
    {
      nixpkgs.config.allowUnfree = true;
      hardware.nvidia = {
        open = cfg.useOpenKernelDrivers;

        modesetting.enable = true;
        nvidiaSettings = true;

        powerManagement.enable = cfg.powerManagement.enable;
        powerManagement.finegrained = cfg.powerManagement.finegrained;

        package = cfg.package;
      };

      # Workaround:
      # https://forums.developer.nvidia.com/t/580-65-06-gtk-4-apps-hang-when-attempting-to-exit-close/341308/3
      environment.sessionVariables = {
        GSK_RENDERER = "ngl";
      };
    }

    (mkIf config.services.xserver.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
    })

    # Allow Plymouth to take over ASAP.
    (mkIf (!config.framework.boot.verbose) {
      boot.initrd.availableKernelModules = [
        "nvidia"
        "nvidia_drm"
        "nvidia_uvm"
        "nvidia_modeset"
      ];
    })

    (mkIf cfg.prime.enable {
      hardware.nvidia.prime = {
        offload.enable = true;
        offload.offloadCmdMainProgram = "prime-run";
        offload.enableOffloadCmd = true;

        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
      };
    })

  ]);
}