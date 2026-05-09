{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf;
  cfg = config.nixos-framework.linux.appimage;
in
{
  options.nixos-framework.linux.appimage = {
    enable = lib.mkEnableOption "add AppImage support" // {
      default = true;
    };
  };

  config = (
    mkIf cfg.enable (mkMerge [

      {
        programs.appimage = {
          enable = true;
          binfmt = true;
        };
      }

    ])
  );
}