{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkDefault;
  cfg = config.nixos-framework.programs.steam;
  primaryUser = config.nixos-framework.primaryUser;
in
{
  options.nixos-framework.programs.steam = {
    enable = lib.mkEnableOption "install Steam";
    enableProtonManager = lib.mkEnableOption "install a Proton management tool" // {
      default = true;
    };
    enableGameMode = lib.mkEnableOption "install GameMode" // {
      default = true;
    };
    enableMangoHud = lib.mkEnableOption "install MangoHud" // {
      default = true;
    };
    enableAdwsSteamGtk = lib.mkEnableOption "enable steam styling" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (mkMerge [

    (
      let
        extraPkgsOptions = [
          {
            # Fix incorrect cursors when using KDE Plasma.
            enable = config.nixos-framework.desktop.plasma.enable;
            packages = pkgs': with pkgs'; [ kdePackages.breeze ];
          }
          {
            # Fix libgamemode.so not existing inside Steam FHS.
            enable = cfg.enableGameMode;
            packages = pkgs': with pkgs'; [ gamemode ];
          }
        ];
        extraPkgs =
          pkgs':
          builtins.foldl' (acc: elem: acc ++ elem) [ ] (
            builtins.map (ep: ep.packages pkgs') (builtins.filter (ep: ep.enable) extraPkgsOptions)
          );
      in
      {
        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
          ];

        programs.steam = {
          enable = true;

          # Steam Remote Play
          remotePlay.openFirewall = true;

          # Source Dedicated Server
          dedicatedServer.openFirewall = true;

          # Steam Local Network Game Transfers
          localNetworkGameTransfers.openFirewall = true;

          # Add extra packages.
          package = pkgs.steam.override { inherit extraPkgs; };
        };

        # Install gamepad drivers.
        nixos-framework.hardware.gamepads.enable = true;

        # Enable HDR via gamescope.
        programs.gamescope.enable = true;
        environment.systemPackages = with pkgs; [
          gamescope-wsi
          nixos-framework.inputs.gamedownsights
        ];

        # Enable ntsync driver.
        boot.kernelModules = [
          "ntsync"
        ];
      }
    )

    (lib.mkIf cfg.enableProtonManager {
      environment.systemPackages = with pkgs; [ protonplus ];
    })

    (lib.mkIf cfg.enableMangoHud {
      environment.systemPackages = with pkgs; [ mangohud ];
    })

    # Install GameMode.
    #
    # https://github.com/FeralInteractive/gamemode
    # https://nixos.wiki/wiki/Gamemode
    (lib.mkIf cfg.enableGameMode (
      let
        normalUsers = (lib.attrsets.filterAttrs (key: val: val.isNormalUser) config.users.users);
      in
      {
        programs.gamemode.enable = true;
        users.groups.gamemode.members = builtins.attrNames normalUsers;
      }
    ))

    (lib.mkIf cfg.enableAdwsSteamGtk {
      home-manager.users.${primaryUser} = { config, osConfig, ... }: {
        home.packages = [ pkgs.adwsteamgtk ];

        home.activation = let
          applySteamTheme = pkgs.writeShellScript "applySteamTheme" ''
            # This file gets copied with read-only permission from the nix store
            # if it is present, it causes an error when the theme is applied. Delete it.
            custom="$HOME/.cache/AdwSteamInstaller/extracted/custom/custom.css"
            if [[ -f "$custom" ]]; then
              rm -f "$custom"
            fi
            ${lib.getExe pkgs.adwsteamgtk} -i
          '';
        in {
          updateSteamTheme = config.lib.dag.entryAfter [ "writeBoundary" "dconfSettings" ] ''
            run ${applySteamTheme}
          '';
        };

        dconf.settings."io/github/Foldex/AdwSteamGtk".prefs-install-custom-css = true;

        xdg.configFile."AdwSteamGtk/custom.css".text = with osConfig.lib.stylix.colors; ''
          :root {
            /* The main accent color and the matching text value */
            --adw-accent-bg-rbg: ${base0D-rgb-r}, ${base0D-rgb-g}, ${base0D-rgb-b};
            --adw-accent-fg-rbg: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-accent-rgb: ${base0D-rgb-r}, ${base0D-rgb-g}, ${base0D-rgb-b};

            /* destructive-action buttons */
            --adw-destructive-bg-rgb: ${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b};
            --adw-destructive-fg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-destructive-rgb: ${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b};

            /* Levelbars, entries, labels and infobars. These don't need text colors */
            --adw-success-bg-rgb: ${base0B-rgb-r}, ${base0B-rgb-g}, ${base0B-rgb-b};
            --adw-success-fg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-success-rgb: ${base0B-rgb-r}, ${base0B-rgb-g}, ${base0B-rgb-b};

            --adw-warning-bg-rgb: ${base0E-rgb-r}, ${base0E-rgb-g}, ${base0E-rgb-b};
            --adw-warning-fg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-warning-fg-a: 0.8;
            --adw-warning-rgb: ${base0E-rgb-r}, ${base0E-rgb-g}, ${base0E-rgb-b};

            --adw-error-bg-rgb: ${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b};
            --adw-error-fg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-error-rgb: ${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b};

            /* Window */
            --adw-window-bg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-window-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};

            /* Views - e.g. text view or tree view */
            --adw-view-bg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-view-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};

            /* Header bar, search bar, tab bar */
            --adw-headerbar-bg-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-headerbar-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};
            --adw-headerbar-border-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-headerbar-backdrop-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-headerbar-shade-rgb: 0, 0, 0;
            --adw-headerbar-shade-a: 0.9;

            /* Split pane views */
            --adw-sidebar-bg-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-sidebar-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};
            --adw-sidebar-backdrop-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-sidebar-shade-rgb: 0, 0, 0;
            --adw-sidebar-shade-a: 0.36;

            --adw-secondary-sidebar-bg-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-secondary-sidebar-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};
            --adw-secondary-sidebar-backdrop-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-secondary-sidebar-shade-rgb: 0, 0, 0;
            --adw-secondary-sidebar-shade-a: 0.36;

            /* Cards, boxed lists */
            --adw-card-bg-rgb: 0, 0, 0;
            --adw-card-bg-a: 0.08;
            --adw-card-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};
            --adw-card-shade-rgb: 0, 0, 0;
            --adw-card-shade-a: 0.36;

            /* Dialogs */
            --adw-dialog-bg-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-dialog-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};

            /* Popovers */
            --adw-popover-bg-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-popover-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};
            --adw-popover-shade-rgb: ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b};
            --adw-popover-shade-a: 0.36;

            /* Thumbnails */
            --adw-thumbnail-bg-rgb: ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b};
            --adw-thumbnail-fg-rgb: ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b};

            /* Miscellaneous */
            --adw-shade-rgb: 0, 0, 0;
            --adw-shade-a: 0.36;
          }
        '';
      };
    })

  ]);
}