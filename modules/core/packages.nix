{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkEnableOption optionals;
  cfg = config.framework.core.pkgs;

  hasEditor = config.framework.programs.nixvim.default;
  # || config.framework.programs.helix.default; Here as a reference
in {
  options.framework.core.pkgs = {
    disk-utils.enable = mkEnableOption "disk utilities" // {default = true;};
    network-utils.enable = mkEnableOption "network utilities" // {default = true;};
    monitoring.enable = mkEnableOption "monitoring tools" // {default = true;};
    fortune.enable = mkEnableOption "fortune" // {default = true;};
  };

  config = mkMerge [
    {
      environment.systemPackages = with pkgs;
        [
          coreutils
          git
          cifs-utils
        ]
        ++ optionals cfg.disk-utils.enable [gdu hdparm unrar unzip zip rsync rclone]
        ++ optionals cfg.network-utils.enable [dig inetutils curl ethtool]
        ++ optionals cfg.monitoring.enable [htop iotop lshw lm_sensors]
        ++ optionals cfg.fortune.enable [fortune];

      environment.shellAliases = {
        pull = "sudo git pull origin main";
        rb = "sudo nixos-rebuild switch --flake .#";
      };
    }

    # Fallback Editor
    (mkIf (!hasEditor) {
      environment.systemPackages = [pkgs.nano];
      environment.variables.EDITOR = "nano";
    })

    {
      programs.bash.enable = true;
      programs.bash.undistractMe.enable = true;
      home-manager.users.${config.framework.primaryUser} = {
        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          options = ["--cmd cd"];
        };
        programs.eza = {
          enable = true;
          icons = "always";
          git = true;
        };
        programs.bat = {
          enable = true;
        };

        home.shellAliases = {
          cat = "bat";
          ls = "eza";
        };
      };
    }
  ];
}

