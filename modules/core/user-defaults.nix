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
    pdf = mkOption {
      type = types.nullOr appType;
      default = null;
    };
    zip = mkOption {
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

      DG_DATA_HOME = "$HOME/.local/share";
      FILEMANAGER = mkIf (cfg.fileManager != null) cfg.fileManager.cmd;
    };

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
              "x-scheme-handler/ssh" = mkIf (cfg.terminal != null) (bindMime cfg.terminal);
              "x-scheme-handler/telnet" = mkIf (cfg.terminal != null) (bindMime cfg.terminal);

              "text/html" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/http" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/https" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/about" = mkIf (cfg.browser != null) (bindMime cfg.browser);
              "x-scheme-handler/unknown" = mkIf (cfg.browser != null) (bindMime cfg.browser);

              "application/pdf" =
                if (cfg.pdf != null)
                then (bindMime cfg.pdf)
                else if (cfg.browser != null)
                then (bindMime cfg.browser)
                else "";

              "text/plain" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "application/x-zerosize" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/markdown" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "application/json" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/css" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/javascript" = mkIf (cfg.editor != null) (bindMime cfg.editor);

              "text/x-chdr" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/x-csrc" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/x-java" = mkIf (cfg.editor != null) (bindMime cfg.editor);
              "text/x-python" = mkIf (cfg.editor != null) (bindMime cfg.editor);

              "inode/directory" = mkIf (cfg.fileManager != null) (bindMime cfg.fileManager);
              "x-scheme-handler/file" = mkIf (cfg.fileManager != null) (bindMime cfg.fileManager);

              "application/zip" = mkIf (cfg.zip != null) (bindMime cfg.zip);
              "application/x-tar" = mkIf (cfg.zip != null) (bindMime cfg.zip);
              "application/x-compressed-tar" = mkIf (cfg.zip != null) (bindMime cfg.zip);
              "application/x-bzip-compressed-tar" = mkIf (cfg.zip != null) (bindMime cfg.zip);
              "application/x-lzma-compressed-tar" = mkIf (cfg.zip != null) (bindMime cfg.zip);
              "application/x-xz-compressed-tar" = mkIf (cfg.zip != null) (bindMime cfg.zip);
            }
            // cfg.extraMimeEntries
          );
      };
    };
  };
}
