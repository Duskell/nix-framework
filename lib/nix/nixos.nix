{ nixos-framework, nixpkgs, ... }@inputs:
{

  # mkNixSystem provides a way to create a NixOS system
  # without having to set up all the manual boilerplate.
  mkNixSystem =
    {
      hostname,
      stateVersion,
      primaryUser
      modules,
    }:
    nixpkgs.lib.nixosSystem {
      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        nixos-framework.nixosModules.nixos-framework

        {
          networking.hostName = hostname;
          system.stateVersion = stateVersion;
        }

        {
          users.users.${primaryUser} = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "sshkeys" ];
          };
          nixos-framework.core.primaryUser = primaryUser;
        }

        {
          nixpkgs.overlays = [
            nixos-framework.overlays.default
            nixos-framework.inputs.nix-cachyos-kernel.overlay
          ];
        }
      ]
      ++ modules;

      specialArgs = {
        nixos-framework = nixos-framework // {
          inherit inputs;
        };
      };
    };

}