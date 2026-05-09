# https://nixos.wiki/wiki/Podman
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.nixos-framework.services.podman;
in
{
  options.nixos-framework.services.podman = {
    enable = lib.mkEnableOption "install Podman";
    tui = lib.mkEnableOption "Add Podman-Tui package" // {
      default = true;
    };
    dockerComp = lib.mkOption {
        type = lib.types.submodule {
            options = {
              enable =  lib.mkEnableOption "Create Docker drop-in replacement" // {
                default = true;
              };

              trusted-users = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "users allowed to communicate with the Podman daemon";
                default = [ ];
              };
            };
        };
        default = {};
        description = "Docker compatiblity settings";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    {
      virtualisation.containers.enable = true; 
      virtualisation.podman.enable = true;
      virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
      virtualisation.podman.dockerCompat = cfg.dockerComp;
      virtualisation.podman.dockerSocket.enable = cfg.dockerComp;

      environment.systemPackages = with pkgs; ([
        dive           # look into docker image layers
        podman-compose # start group of containers for dev
      ]
      ++ lib.optional cfg.dockerComp docker-compose
      ++ lib.optional cfg.tui podman-tui # status of containers in the terminal
      );
    }

    # Add trusted users to the Docker group.
    (mkIf cfg.dockerComp.enable {
      users.groups.podman.members = cfg.dockerComp.trusted-users;
    })
  ]);
}