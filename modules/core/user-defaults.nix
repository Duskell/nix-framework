{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = config.framework.defaults;
  desktop = config.framework.desktop;
  primaryUser = config.framework.primaryUser;

  appType = types.submodule {
    options = {
      cmd = mkOption {
        type = types.str;
        description = "The exact executable command line string (e.g., 'alacritty', 'vicinae open').";
      };
      desktop = mkOption {
        type = types.nullOr types.str;
        description = "The exact name of the desktop entry file without extension (e.g., 'Alacritty', 'firefox').";
      };
    };
  };
in {
  options.framework.defaults = {
    browser = mkOption {
      type = types.nullOr appType;
      default = null;
    };
    terminal = mkOption {
      type = types.nullOr appType;
      default = null;
    };
    editor = mkOption {
      type = types.nullOr appType;
      default = null;
    };
    fileManager = mkOption {
      type = types.nullOr appType;
      default = null;
    };
    launcher = mkOption {
      type = types.nullOr appType;
      default = null;
    };

    extraMimeEntries = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra manual XDG MIME application mappings.";
    };
  };

  config = {
    environment.variables = {
      EDITOR = mkIf (cfg.editor != null) cfg.editor.cmd;
      VISUAL = mkIf (cfg.editor != null) cfg.editor.cmd;
      BROWSER = mkIf (cfg.browser != null) cfg.browser.cmd;
      TERMINAL = mkIf (cfg.terminal != null) cfg.terminal.cmd;
    };

    # 2. XDG Graphical Integration (Only evaluated if a desktop environment is active)
    home-manager.users.${primaryUser} = mkIf (desktop.enable && primaryUser != null) {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = let
          bindMime = app:
            if app ? desktop && app.desktop != null
            then "${app.desktop}.desktop"
            else "";
        in
          lib.filterAttrs (name: val: val != "") (
            {
              "text/html" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/http" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/https" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/about" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/unknown" = mkIf (cfg.browser != null) (bindMime cfg.browser);

              "text/plain" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "application/x-zerosize" = mkIf (cfg.editor != null) (bindMime cfg.editor);

              "inode/directory" = mkIf (cfg.fileManager != null) (bindMime cfg.fileManager);
            }
            // cfg.extraMimeEntries
          );
      };
    };
  };
}
