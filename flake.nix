# Derived from: https://github.com/eth-p/my-nixos
# Original Copyright (C) 2025 eth-p
#
# Copyright (C) 2026 Duskell
# Repo: https://github.com/Duskell/nix-config
{
  description = ''
    The NixOS flake framework used on all my machines.
  '';
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel = {
      url                    = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url                    = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url                    = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url                    = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-effects-better-blur = {
      url                    = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url                    = "github:gmodena/nix-flatpak?refs=latest";
    };
    copyparty = {
      url                    = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url                    = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url                    = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url                    = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gamedownsights = {
      url                    = "github:eth-p/gamedownsights";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = 
    { self, nixpkgs, ... }@inputs:
    rec {

      lib = (import ./lib/nix) (
        {
          lib   = nixpkgs.lib;
          nixos-framework = self;          
        }
        // inputs
      );

      # packages evaluates ./packages/overlay.nix, returning a package
      # derivation for each of the overlayed packages.
      packages =
        let
          forEachSystem = nixpkgs.lib.genAttrs systems;
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        in
        forEachSystem (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.packages ];
            };
          in
          nixpkgs.lib.attrsets.mapAttrs (name: value: pkgs."${name}") (self.overlays.packages pkgs pkgs)
        );

      # overlays provides nixpkgs overlays.
      overlays = {
        default = final: prev: (overlays.externals prev final) // (overlays.packages prev final);

        packages = (import ./packages/overlay.nix);
        externals = (
          final: prev:
          let
            system = prev.stdenv.hostPlatform.system;
          in
          rec {
            kde-kwin-effects-better-blur-dx-wayland = inputs.kwin-effects-better-blur-dx.packages.${system}.default;
            kde-kwin-effects-better-blur-dx-x11 = inputs.kwin-effects-better-blur-dx.packages.${system}.x11;
            kde-kwin-effects-forceblur-wayland = kde-kwin-effects-better-blur-dx-wayland;
            kde-kwin-effects-forceblur-x11 = kde-kwin-effects-better-blur-dx-x11;
            copyparty = inputs.copyparty.overlays.default;
          }
        );
      };

      # nixosModules provides NixOS modules.
      nixosModules = {
        nixos-framework = {
          imports = (import ./modules);
        };
      };

    };
}