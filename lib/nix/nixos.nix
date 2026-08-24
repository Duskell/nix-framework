{
  framework,
  nixpkgs,
  ...
} @ inputs: {
  # mkNixSystem provides a way to create a NixOS system
  # without having to set up all the manual boilerplate.
  mkNixSystem = {
    package,
    hostname,
    system,
    stateVersion,
    primaryUser,
    modules ? [],
  }: let
    lib = nixpkgs.lib;
    validPackages = ["standard" "lix"];
    isValidPackage = lib.elem package validPackages;
  in
    assert lib.assertMsg isValidPackage
    "mkNixSystem: 'package' must be one of [${lib.concatStringsSep ", " validPackages}], but got '${package}'.";
      lib.nixosSystem {
        inherit system;

        modules =
          [
            inputs.lanzaboote.nixosModules.lanzaboote
            framework.nixosModules.framework

            {
              networking.hostName = hostname;
              system.stateVersion = stateVersion;
            }

            {
              users.users.${primaryUser} = {
                isNormalUser = true;
                extraGroups = ["wheel" "networkmanager" "sshkeys"];
                initialPassword = "changeme";
              };
              framework.primaryUser = primaryUser;
            }

            {
              nixpkgs.overlays =
                [
                  framework.overlays.default
                ]
                ++ lib.optional (package
                  == "lix") (final: prev: {
                  inherit
                    (prev.lixPackageSets.stable)
                    nixpkgs-review
                    nix-eval-jobs
                    nix-fast-build
                    colmena
                    ;
                });
            }

            ({
              pkgs,
              lib,
              ...
            }:
              lib.mkIf (package == "lix") {
                nix.package = pkgs.lixPackageSets.stable.lix;
              })
          ]
          ++ modules;

        specialArgs =
          inputs
          // {
            framework =
              framework
              // {
                # placeholder
              };
          };
      };
}
