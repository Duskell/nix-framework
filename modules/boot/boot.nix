{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.boot;
in
{
  options.framework.boot = {
    secure-boot.enable = lib.mkEnableOption "Secure Boot using lanzaboote";
    tpm-unlock.enable = lib.mkEnableOption "use TPM to unlock LUKS-encrypted volumes";

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "show a verbose boot screen";
    };
  };

  config = mkMerge [

    # Use the systemd-boot EFI boot loader.
    {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot = {
        enable = true;
        editor = lib.mkForce false;
      };
      swapDevices = [
        {
          device = "/swapfile";
          size = 1024 * 8;
        }
      ];
    }

    # Use lanzaboote for self-signed Secure Boot.
    # https://github.com/nix-community/lanzaboote
    (mkIf cfg.tpm-unlock.enable {
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      environment.systemPackages = with pkgs; [ sbctl ];
    })

    # Enable features required for unlocking volumes via TPM 2.0.
    # Before enabling this, you must manually enroll the keys:
    #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/the-disk
    (mkIf cfg.secure-boot.enable {
      boot.initrd.systemd.enable = true;
      environment.systemPackages = with pkgs; [ tpm2-tss ];
    })

    # If verbose booting is disabled, hide the syslog using Plymouth.
    (mkIf (!cfg.verbose) {
      boot.plymouth = {
        enable = true;
        theme = mkDefault "bgrt";
      };

      boot.kernelParams = [
        # Fix for broken Plymouth on NixOS with CachyOS kernel.
        # https://github.com/chaotic-cx/nyx/issues/946
        "plymouth.ignore-serial-consoles"

        # Hide verbose boot messages.
        "quiet"
        "splash"
        "rd.systemd.show_status=auto"
      ];
    })

    (mkIf config.framework.hardware.cpu.intel.enable {
      boot.kernelParams = [
        "intel_pstate=active"
        "intel_iommu=on"
        "iommu=pt"
      ];
      boot.kernelModules = [ "i915" ];
    })

  ];
}