{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (framework.lib) gpus;
  cfg = config.framework.hardware.graphics;
in {
  options.framework.hardware.graphics = {
    enable = lib.mkEnableOption "enable graphics stack";
    card = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames gpus.cards));
      default = null;
      description = "the main graphics card installed in the system";
    };
    igpu = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames gpus.cards));
      default = null;
      description = "optional integrated graphics card for hardware acceleration";
    };
    vulkan = lib.mkEnableOption "Enable Vulkan";
  };

  config = let
    primaryGPU = gpus.cardByName cfg.card;
    integratedGPU = gpus.cardByName cfg.igpu;
  in
    mkIf cfg.enable (mkMerge [
      # Enable graphics support.
      {
        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

        # Enable X11.
        services.xserver.enable = true;
        services.xserver.xkb = {
          layout = "hu";
          variant = "standard";
        };

        xdg.portal.enable = true;

        # Needed for new default, placed here by a lack of better ideas
        gtk.gtk4.theme = null;
      }

      # Enable NVIDIA drivers.
      (mkIf (gpus.isNvidia primaryGPU) {
        framework.drivers.nvidia = {
          enable = true;
        };
      })

      (mkIf (integratedGPU != null) {
        hardware.graphics.extraPackages = with pkgs;
          if integratedGPU.vendor == gpus.vendors.intel
          then [
            intel-media-driver
            libvdpau-va-gl
            libva-vdpau-driver
          ]
          else if integratedGPU.vendor == gpus.vendors.amd
          then [
            libvdpau-va-gl
            libva-vdpau-driver
          ]
          else [];
      })

      # Enable Vulkan packages.
      (mkIf cfg.vulkan {
        hardware.graphics.extraPackages = with pkgs; [
          vulkan-loader
          vulkan-validation-layers
          vulkan-tools
        ];
        hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
          vulkan-loader
        ];
      })
    ]);
}

