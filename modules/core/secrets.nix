{ inputs, config, lib, pkgs, nixos-framework, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];

  options.nixos-framework.core.secrets = {
    enable = lib.mkEnableOption "enable agenix secrets management" // {
      default = true;
    };
    cli = lib.mkEnableOption "enable agenix cli" // {
      default = true;
    };

    # list of secrets to add later
    items = lib.mkOption {
      description = "custom managed secrets";
      default = {};
      type = lib.types.attrsOf (lib.types.submodule ( { name, ... }: {
        options = {
          file = lib.mkOption {
            type = lib.types.str;
            default = "${nixos-framework}/secrets/${name}.age"; 
          };
          path = lib.mkOption {
            type = lib.types.str;
            default = "/run/secrets/${name}";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "0400";
          };
          owner = lib.mkOption {
            type = lib.types.str;
            default = config.nixos-framework.core.primaryUser;
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = config.nixos-framework.core.primaryUser;
          };
        };
      }));
    };
  };

  config = lib.mkIf config.nixos-framework.core.secrets.enable {
    # make agenix use the machine's inherent SSH host key for decryption
    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    environment.systemPackages = lib.optional  config.nixos-framework.core.secrets.cli inputs.agenix.packages.${pkgs.system}.default;

    age.secrets = lib.mapAttrs (name: secretConfig: {
      file = secretConfig.file;
      path = secretConfig.path;
      mode = secretConfig.mode;
      owner = secretConfig.owner;
      group = secretConfig.group;
    }) cfg.items;
  };
}