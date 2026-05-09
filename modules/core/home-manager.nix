{ inputs, config, lib, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.overwriteBackup = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit nixcord self;
        };
      }];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = { inherit inputs; };
      
      users.${config.nixos-framework.core.primaryUser} = {
        home.stateVersion = config.system.stateVersion;
      };
    };
  };
}