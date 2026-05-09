{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (nixos-framework.lib) gpus;
  cfg = config.nixos-framework.hardware.graphics;
in
{
  options.nixos-framework.hardware.graphics = {
    enable = lib.mkEnableOption "enable graphics stack";
    card = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames gpus.cards));
      default = null;
      description = "the main graphics card installed in the system";
    };
    vulkan = lib.mkEnableOption "Enable Vulkan";
  };

  config =
    let
      primaryGPU = gpus.cardByName cfg.card;
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
      }

      # Enable NVIDIA drivers.
      (mkIf (gpus.isNvidia primaryGPU) {
        nixos-framework.drivers.nvidia = {
          enable = true;
          useOpenKernelDrivers = primaryGPU.drivers.nvidia-open;
        };
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