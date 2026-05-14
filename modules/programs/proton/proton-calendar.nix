{
  config,
  lib,
  pkgs,
  framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (framework.lib.webwrap) mkChromiumApp;
  cfg = config.framework.programs.proton.proton-calendar;
in
{
  options.framework.programs.proton.proton-calendar = {
    enable = lib.mkEnableOption "install a ProtonMail Calendar wrapper";

    package = lib.mkOption {
      type = lib.types.package;
      description = "the wrapper app package";
      default = mkChromiumApp pkgs {
        appName = "proton-calendar";
        configDirName = "proton";
        url = "https://calendar.proton.me/u/0/";

        icon = "${./assets/proton-calendar.png}";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # Install the Chromium wrapper.
    {
      environment.systemPackages = [
        cfg.package
      ];
    }

  ]);
}