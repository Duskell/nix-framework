{
  config,
  lib,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) optional optionals mkMerge mkIf;
  cfg = config.framework.core.pkgs;

  hasEditor = config.framework.programs.neovim.default;
          # || config.framework.programs.helix.default; Here as a reference
in
{
  options.framework.core.pkgs = {
    disk-utils.enable = lib.mkEnableOption "Enable disk utility tools" // {
      default = true;
    };
    network-utils.enable = lib.mkEnableOption "Enable network utility tools" // {
      default = true;
    };
    monitoring.enable = lib.mkEnableOption "Enable hardware and process monitoring tools" // {
      default = true;
    };
    fortune.enable = lib.mkEnableOption "Enable the most important part of the system" // {
      default = true;
    };
  };

  config = mkMerge [
    {
    environment.systemPackages = with pkgs; ([
      coreutils  # The GNU Core Utils
      bat        # A cat clone with syntax highlighting and Git integration
      zoxide     # A better cd
      eza        # A Better ls in written in rust
      cifs-utils # Tools for managing Linux CIFS client filesystems
      git        #
    ]
    ++ optionals cfg.disk-utils.enable [
      gdu    # Disk Usage/Free Utility
      hdparm # A tool to get/set ATA/SATA drive parameters under Linux
      unrar  # Utility for RAR archives
      unzip  # An extraction utility for archives compressed in .zip format
      zip    # Compressor/archiver for creating and modifying zipfiles
      rsync  # Fast incremental file transfer utility between two devices
      rclone # Same as Rsync just for cloud stuff (e.g. GDrive)
    ]
    ++ optionals cfg.network-utils.enable [
      dig       # A DNS tool
      inetutils # Collection of common network programs
      curl      #
      ethtool   # Utility for controlling network drivers and hardware
    ]
    ++ optionals cfg.monitoring.enable [
      htop       # An interactive process viewer
      iotop      # A tool to find out the processes doing the most IO
      lshw       # Provide detailed information on the hardware configuration of the machine
      lm_sensors # Tools for reading hardware sensors
    ]
    ++ optional cfg.fortune.enable fortune);

    environment.shellInit = ''
      eval "$(zoxide init bash)"
      alias ls="eza --icons=always"
      alias ll="eza -la --icons=always"
      alias cat="bat" # Use bat for cat
      alias cd="z"
      alias pull='sudo git pull origin main'
      alias rb='sudo nixos-rebuild switch --flake .#'
    '';
    }

    (mkIf (!hasEditor) {
      environment.systemPackages = [ pkgs.nano ];
      environment.variables.EDITOR = "nano";
    })
  ];
}