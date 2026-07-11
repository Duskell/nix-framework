# Derived from: https://github.com/eth-p/my-nixos
# Original Copyright (C) 2025 eth-p
#
# Copyright (C) 2026 Duskell
# Repo: https://github.com/Duskell/nix-framework
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
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-effects-better-blur = {
      url = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak?refs=latest";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gamedownsights = {
      url = "github:eth-p/gamedownsights";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: rec {
    lib = (import ./lib/nix) (
      {
        lib = nixpkgs.lib;
        framework = self;
      }
      // inputs
    );

    # packages evaluates ./packages/overlay.nix, returning a package
    # derivation for each of the overlayed packages.
    packages = let
      forEachSystem = nixpkgs.lib.genAttrs systems;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
      forEachSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [self.overlays.packages];
          };
        in
          nixpkgs.lib.attrsets.mapAttrs (name: value: pkgs."${name}") (self.overlays.packages pkgs pkgs)
      );

    # overlays provides nixpkgs overlays.
    overlays = {
      default = final: prev: (overlays.externals final prev) // (overlays.packages prev final);

      packages = import ./packages/overlay.nix;
      externals = (
        final: prev: let
          system = prev.stdenv.hostPlatform.system;
        in rec {
          kde-kwin-effects-better-blur-dx-wayland = inputs.kwin-effects-better-blur-dx.packages.${system}.default;
          kde-kwin-effects-better-blur-dx-x11 = inputs.kwin-effects-better-blur-dx.packages.${system}.x11;
          kde-kwin-effects-forceblur-wayland = kde-kwin-effects-better-blur-dx-wayland;
          kde-kwin-effects-forceblur-x11 = kde-kwin-effects-better-blur-dx-x11;
          copyparty = inputs.copyparty.overlays.default;

          #vulkan-validation-layers = prev.vulkan-validation-layers.overrideAttrs (oldAttrs: {
          #  cmakeFlags =
          #    (oldAttrs.cmakeFlags or [])
          #    ++ [
          #      "-DUPDATE_DEPS=OFF"
          #  ];
          #});

          arandr = prev.arandr.overrideAttrs (oldAttrs: {
            # Remove the custom build_man step that crashes on Setuptools >= 81
            postPatch =
              (oldAttrs.postPatch or "")
              + ''
                # Strip both legacy distutils commands from cmdclass and sub_commands
                sed -i -E "/'(build_man|build_i18n)'/d" setup.py

                # Remove the locale directory from data_files so wheel packaging doesn't look for it
                sed -i "/'build\/locale'/d" setup.py
              '';
          });

          # A fix for i686 openldap tests, which trigger and fail mistakenly, causing a cascade of rebuilds.
          # See https://github.com/NixOS/nixpkgs/issues/514113
          #openldap = prev.openldap.overrideAttrs {
          # doCheck = !prev.stdenv.hostPlatform.isi686;
          #};
        }
      );
    };

    # nixosModules provides NixOS modules.
    nixosModules = {
      framework = {
        imports = import ./modules;
      };
    };

    # For debugging purposes
    checks = let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
      forEachSystem (
        system: let
          pkgs = import nixpkgs {
            inherit system;
          };

          eval = lib.nixos.mkNixSystem {
            hostname = "test";
            system = system;
            stateVersion = "25.05";
            primaryUser = "duskell";
            modules = [
              {
                fileSystems."/" = {
                  device = "/dev/disk/by-label/nixos"; # or a UUID
                  fsType = "ext4";
                };
              }
            ];
          };
        in {
          framework = eval.config.system.build.toplevel;
        }
      );
  };
}
