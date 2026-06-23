{
  config,
  lib,
  pkgs,
  ...
} @ inputs: let
  inherit (lib) mkIf mkMerge;
  cfg = config.framework.services.nix;
in {
  options.framework.services.nix = {
    flakes =
      lib.mkEnableOption "enable support for flakes"
      // {
        default = true;
      };

    unfree =
      lib.mkEnableOption "enable unfree packages"
      // {
        default = true;
      };

    command-not-found =
      lib.mkEnableOption "enable command-not-found"
      // {
        default = false;
      };

    dirty-git =
      lib.mkEnableOption "enable git repo is dirty warning"
      // {
        default = false;
      };

    trusted-users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "trusted users";
      default = [];
    };

    cache.devenv.enable = lib.mkEnableOption "enable devenv binary cache";
    cache.vicinae.enable = lib.mkEnableOption "enable vicinae binary cache";
    cache.hyprland.enable = lib.mkEnableOption "enable hyprland binary cache";
    cache.cachyos-kernel.enable = lib.mkEnableOption "enable cachyos-kernel binary cache";
  };

  config = mkMerge [
    # Enable Nix flakes and the `nix` command.
    (mkIf cfg.flakes {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = with pkgs; [
        git # Used to pull flakes
      ];
    })

    # Allow installing unfree packages.
    (mkIf cfg.unfree {
      nixpkgs.config.allowUnfree = true;
    })

    # Show potential packages for unknown commands.
    (mkIf cfg.command-not-found {
      programs.command-not-found.enable = true;
    })

    # Warns when the git tree is dirty.
    (mkIf (!cfg.dirty-git) {
      nix.settings.warn-dirty = false;
    })

    # Enable devenv binary cache.
    (mkIf cfg.cache.devenv.enable {
      nix.settings = {
        extra-substituters = ["https://devenv.cachix.org"];
        extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
      };
    })

    (mkIf cfg.cache.vicinae.enable {
      nix.settings = {
        extra-substituters = ["https://vicinae.cachix.org"];
        extra-trusted-public-keys = ["vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="];
      };
    })

    (mkIf cfg.cache.hyprland.enable {
      nix.settings = {
        extra-substituters = ["https://hyprland.cachix.org"];
        extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };
    })

    (mkIf cfg.cache.cachyos-kernel.enable {
      nix.settings = {
        extra-substituters = ["https://attic.xuyh0120.win/lantian"];
        extra-trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
      };
    })

    # Set trusted users.
    {
      nix.settings.trusted-users = [config.framework.primaryUser] ++ cfg.trusted-users;
    }
  ];
}
