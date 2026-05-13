{ inputs, config, lib, nixos-framework, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      overwriteBackup = true;

      extraSpecialArgs = { 
        inherit nixos-framework inputs;
        sysConfig = config;
      };
      
      users.${config.nixos-framework.primaryUser} = {
        home.stateVersion = config.system.stateVersion;
      };
    };
  };
}