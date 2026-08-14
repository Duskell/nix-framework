{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.framework.services.copyparty;
in {
  imports = [inputs.copyparty.nixosModules.default];

  options.framework.services.copyparty = {
    enable = lib.mkEnableOption "enable Copyparty";
  };

  config = lib.mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = [pkgs.copyparty];

      services.copyparty = {
        enable = true;
        user = "copyparty";
        group = "copyparty";
        # directly maps to values in the [global] section of the copyparty config.
        # see `copyparty --help` for available options
        settings = {
          i = "0.0.0.0"; # ip
          p = [3200]; # ports
          # use booleans to set binary flags
          no-reload = true;
          shr = "/s";

          # reverse-proxy / Cloudflare real-IP handling
          "xff-hdr" = "cf-connecting-ip"; # header CF fills with the client IP
          "xff-src" = "any"; # or list only the CF CIDRs you allow through
          rproxy = 1;
        };

        accounts = {
          # specify the account name as the key
          levente.passwordFile = "/var/lib/copyparty/levente_password";

          attila.passwordFile = "/var/lib/copyparty/attila_password";
        };

        groups = {
          owner = ["levente"];
          users = ["attila"];
        };

        volumes = {
          "/internal" = {
            path = "/srv/copyparty/internal";
            access = {
              rwmd = ["levente"];
            };
            flags = {
              norobots = true;
              fk = 4;
              scan = 60;
              e2d = true;
              e2t = true;
            };
          };

          "/private" = {
            path = "/srv/copyparty/private";
            # see `copyparty --help-accounts` for available options
            access = {
              # r = "*";
              rwmd = [
                "levente"
                "attila"
              ];
            };
            # see `copyparty --help-flags` for available options
            flags = {
              # "fk" enables filekeys (necessary for upget permission) (4 chars long)
              fk = 4;
              # scan for new files every 60sec
              scan = 60;
              # volflag "e2d" enables the uploads database
              e2d = true;
              # "d2t" disables multimedia parsers (in case the uploads are malicious)
              d2t = true;
              # skips hashing file contents if path matches *.iso
              nohash = ".iso$";

              norobots = true;
            };
          };
        };
        # you may increase the open file limit for the process
        openFilesLimit = 8192;
      };
    }
  ]);
}

