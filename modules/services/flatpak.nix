{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.nixos-framework.services.flatpak;
  primaryUser = config.nixos-framework.core.primaryUser;
in
{
  options.nixos-framework.services.flatpak = {
    enable = lib.mkEnableOption ''
      Whether to enable flatpak
    '';
  };

  config = lib.mkIf cfg.enable (mkMerge [
    {
      home-manager.users.${primaryUser} =
        { inputs, ... }:
        {
          imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
        };
    }
  ]);
}