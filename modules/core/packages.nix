{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkEnableOption optionals;
  cfg = config.framework.core.pkgs;
  fwDefaults = config.framework.defaults;
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

    {
      # Fallback Editor
      framework.defaults.editor = lib.mkDefault {
        cmd = "nano";
        desktop = null;
      };

      environment.systemPackages = lib.mkIf (config.framework.defaults.editor.cmd == "nano") [pkgs.nano];
    }

    {
      # Fallback Browser
      framework.defaults.browser = lib.mkIf config.framework.desktop.enable (lib.mkDefault {
        cmd = "firefox";
        desktop = "Firefox";
      });

      environment.systemPackages = lib.mkIf (config.framework.desktop.enable && config.framework.defaults.browser.cmd == "firefox") [pkgs.firefox];
    }

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
