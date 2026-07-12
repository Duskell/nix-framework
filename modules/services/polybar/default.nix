{
  config,
  lib,
  pkgs,
  framework,
  ...
}: let
  inherit (lib) mkIf mkDefault mkOption mkEnableOption types;
  cfg = config.framework.services.polybar;
in {
  options.framework.services.polybar = {
    enable = mkEnableOption "enable Polybar";

    theme = mkOption {
      type = types.enum ["lines" "floating" "custom"];
      default = "floating";
      description = "The built-in theme to use, if theme is set with direct config then set it to custom";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "These are written directly to the config";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.framework.primaryUser} = {
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
      ];

      services.polybar = let
        finalConfig =
          if cfg.theme == "custom"
          then cfg.settings
          else (import ./themes/${cfg.theme}.nix {inherit pkgs framework config;}) // cfg.settings;

        allKeys = builtins.attrNames finalConfig;
        barKeys = builtins.filter (key: builtins.substring 0 4 key == "bar/") allKeys;
        barNames = map (key: builtins.substring 4 (builtins.stringLength key) key) barKeys;

        spacerBars = builtins.filter (name: name == "spacer") barNames;
        islandBars = builtins.filter (name: name != "spacer") barNames;

        launchSpacer = lib.strings.concatStringsSep "\n" (map (name: "polybar -q -r ${name} &") spacerBars);
        launchIslands = lib.strings.concatStringsSep "\n" (map (name: "polybar -q -r ${name} &") islandBars);
      in {
        enable = true;

        package = pkgs.polybar.override {
          i3Support = true;
          pulseSupport = true;
        };

        script = ''
          export PATH="${lib.makeBinPath (with pkgs; [coreutils procps gnugrep gnused playerctl cava vicinae python312])}:$PATH"
          ${launchSpacer}
          ${lib.optionalString (spacerBars != []) "sleep 0.5"}
          ${launchIslands}
        '';

        config = finalConfig;
      };
    };
  };
}
