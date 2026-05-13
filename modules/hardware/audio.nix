# https://wiki.nixos.org/wiki/Category:Audio
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.nixos-framework.hardware.audio;
in
{
  options.nixos-framework.hardware.audio = {
    enable = lib.mkEnableOption "enable audio";

    pipewire = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Use Pipewire, the modern sound subsystem" // {
            default = true;
          };
          jack.enable = lib.mkEnableOption "Use JACK applications";
        };
        default = {};
        description = "Pipewire settings";
      };

    };
    rtkit.enable = lib.mkEnableOption "Enable RealtimeKit for audio purposes" // {
      default = true;
    };
    
  };

  config = mkIf cfg.enable (mkMerge [
    {
      users.extraUsers.${config.nixos-framework.primaryUser}.extraGroups = [ "audio" ];

      security.rtkit.enable = cfg.rtkit.enable;
    }

    (lib.mkIf cfg.pipewire.enable (mkMerge  [
      {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      }

      (lib.mkIf cfg.pipewire.jack.enable {
        services.pipewire.jack.enable = true;
      })
    ]))

  ]);
}
