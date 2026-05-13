# This provides a consistent environment for running development scripts.
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.fast = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkMerge [
    {
      packages = [
        pkgs.git
        pkgs.nix-update

        # Formatters
        pkgs.treefmt
        pkgs.shfmt
        pkgs.nixfmt-rfc-style
      ];

      # https://devenv.sh/tasks/
      tasks = {
        "framework:format" = {
          exec = "treefmt";
        };
      };
    }

    # Configuration applied when not using direnv.
    (lib.mkIf (!config.fast) (
      let
        system = pkgs.stdenv.system;
      in {
        packages = [
          inputs.nix-options-doc.packages.${system}.default
        ];

        # https://devenv.sh/tasks/
        tasks = {
          "framework:docs" = {
            before = ["framework:format"];
            exec = ''
              nix-options-doc \
                --path "." \
                --out OPTIONS.md \
                --exclude-dir "lib" \
                --exclude-dir "profiles" \
                --filter-by-prefix "options.nixos-framework" \
                --strip-prefix "options." \
                --sort
            '';
          };
        };
      }
    ))
  ];
}

