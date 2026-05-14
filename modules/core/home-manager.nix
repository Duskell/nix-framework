{ inputs, config, lib, framework, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      overwriteBackup = true;

      extraSpecialArgs = { 
        inherit framework inputs;
        sysConfig = config;
      };
      
      users.${config.framework.primaryUser} = {
        home.stateVersion = config.system.stateVersion;
      };
    };
  };
}