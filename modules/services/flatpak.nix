# https://github.com/gmodena/nix-flatpak/tree/main
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.services.flatpak;
  primaryUser = config.framework.primaryUser;
in
{
  options.framework.services.flatpak = {
    enable = lib.mkEnableOption ''
      Whether to enable flatpak
    '';

    remotes = lib.mkOption {
      type = lib.type.anything;
      default = [];
      description = ''
        The extra remotes to add besides the default: "flathub"
      '';
    };

    packages = lib.mkOption {
      type = lib.type.anything;
      default = [];
      description = ''
        List of flatpak packages to add
      '';
    };
  };

  config = lib.mkIf cfg.enable (mkMerge [
    {
      home-manager.users.${primaryUser} =
        { ... }:
        let 
          cfg = config.framework.services.flatpak;
        in
        {
          imports = [
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
          ];

          services.flatpak.enable = true;
          services.flatpak.remotes = lib.mkOptionDefault  cfg.remotes;
          services.flatpak.packages = cfg.packages;
        };
    }
  ]);
}