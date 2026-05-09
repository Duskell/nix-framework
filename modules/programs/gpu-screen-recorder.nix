# Wiki:     https://wiki.nixos.org/wiki/Gpu-screen-recorder
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf;
  cfg = config.nixos-framework.programs.gpu-screen-recorder;
in
{
  options.nixos-framework.programs.gpu-screen-recorder = {
    enable = lib.mkEnableOption "install gpu-screen-recorder";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The package for gpu-screen-recorder.";
      default = pkgs.gpu-screen-recorder;
    };

    ui = {
      enable = lib.mkEnableOption "install a UI for gpu-screen-recorder" // {
        default = true;
      };

      package = lib.mkOption {
        type = lib.types.package;
        description = "The UI package for gpu-screen-recorder.";
        default = pkgs.gpu-screen-recorder-ui;
      };

      autostart = lib.mkOption {
        type = lib.types.bool;
        description = "start gpu-screen-recorder on login";
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable (mkMerge [

    {
      security.wrappers = {
        "gsr-kms-server" = {
          owner = "root";
          group = "root";
          capabilities = "cap_sys_admin+ep";
          source = lib.getExe' cfg.package "gsr-kms-server";
        };
      };

      environment.systemPackages = [
        cfg.package
      ];
    }

    (mkIf cfg.ui.enable {
      security.wrappers = {
        "gsr-global-hotkeys" = {
          owner = "root";
          group = "root";
          capabilities = "cap_setuid+ep";
          source = lib.getExe' cfg.ui.package "gsr-global-hotkeys";
        };
      };

      environment.systemPackages = with pkgs; [
        cfg.ui.package
        pkgs.gpu-screen-recorder-notification
      ];
    })

    # Add systemd user service for starting gpu-screen-recorder on login.
    (mkIf (cfg.ui.enable && cfg.ui.autostart) {
      systemd.user.services.gpu-screen-recorder = {
        enable = true;
        wantedBy = [ "graphical-session.target" ];
        description = "GPU Screen Recorder Overlay";
        serviceConfig = {
          Type = "simple";
          ExecStart = cfg.ui.package + "/bin/" + cfg.ui.package.meta.mainProgram;
          Restart = "on-failure";
          RestartSec = 30;
        };
      };
    })

  ]);
}