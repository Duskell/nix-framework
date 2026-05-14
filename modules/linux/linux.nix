{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf;
  cfg = config.framework.linux;
in
{
  options.framework.linux = {
    kernel = lib.mkOption {
      type = lib.types.enum [
        "latest"
        "cachyos"
        "cachyos-zen4"
      ];
      default = "latest";
      description = "the Linux kernel packages";
    };

    quiet-consoles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "suppress kernel messages on the specified TTYs";
      example = ''[ "tty2" "tty3" ]'';
    };
  };

  config = mkMerge [

    # Use a specific kernel package.
    (
      let
        kernels = {
          "latest" = pkgs.linuxPackages_latest;
          "cachyos" = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
          "cachyos-zen4" = pkgs.linuxKernel.packagesFor (
            pkgs.cachyosKernels.linux-cachyos-latest.overrideAttrs (old: {
              NIX_CFLAGS_COMPILE = [
                (old.NIX_CFLAGS_COMPILE or "")
                "-march=znver4"
              ];
            })
          );
        };
      in
      {
        boot.kernelPackages = kernels."${cfg.kernel}";
      }
    )

    # Install useful tools.
    {
      environment.systemPackages = with pkgs; [
        usbutils
        pciutils
        file
        pv
        killall
        smartmontools
        iotop
      ];
    }

    # Enable features required for unlocking volumes via TPM 2.0.
    # Before enabling this, you must manually enroll the keys:
    #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/the-disk
    (mkIf ((builtins.length cfg.quiet-consoles) > 0) {
      systemd.services.quiet-consoles = {
        description = "Suppress kernel messages on specific consoles";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            /bin/sh -c 'for tty in ${pkgs.lib.escapeShellArgs cfg.quiet-consoles}; do \
              if [ -e "/dev/$tty" ]; then \
                /run/current-system/sw/bin/setterm -msg off -term linux <"/dev/$tty" >"/dev/$tty"; \
              fi \
            done'
          '';
        };
      };
    })

  ];
}