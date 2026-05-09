{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (nixos-framework.lib) desktops;
  cfg = config.nixos-framework.desktop;
in
{
  imports = [ 
    ./de
    ./dm
  ];

  options.nixos-framework.desktop = {
    enable = lib.mkEnableOption "use a graphical desktop environment";

    environment = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames desktops.environments));
      default = null;
      description = "the desktop environment to use";
    };
  };

  config =
    let
      de = desktops.environmentByName cfg.environment;
      wayland = desktops.usesWayland de;
    in
    mkIf cfg.enable (mkMerge [

      {
        nixos-framework.desktop.${de.dm}.enable = true;
        nixos-framework.desktop.${de.flavor}.enable = true;
        services.displayManager.defaultSession = de.flavor;
      }

      # Enable Wayland and install wayland-related packages.
      (mkIf wayland {
        services.displayManager.sddm.wayland.enable = true;
        environment.systemPackages = with pkgs; [
          wayland-utils
          wl-clipboard
        ];
      })

      # Install X11-related packages.
      (mkIf (!wayland) {
        environment.systemPackages = with pkgs; [
          xclip
        ];
      })
    ]);
}