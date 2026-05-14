{ framework, nixpkgs, ... }@inputs:
{

  # mkNixSystem provides a way to create a NixOS system
  # without having to set up all the manual boilerplate.
  mkNixSystem =
    {
      hostname,
      system,
      stateVersion,
      primaryUser,
      modules ? [],
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        framework.nixosModules.framework

        {
          networking.hostName = hostname;
          system.stateVersion = stateVersion;
        }

        {
          users.users.${primaryUser} = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "sshkeys" ];
            initialPassword = "changeme";
          };
          framework.primaryUser = primaryUser;
        }

        {
          nixpkgs.overlays = [
            framework.overlays.default
            framework.inputs.nix-cachyos-kernel.overlay
          ];
        }
      ]
      ++ modules;

      specialArgs = {
        inherit inputs;
        framework = framework // {
          # placeholder
        };
      };
    };

}