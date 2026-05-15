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
  cfg = config.framework.programs.proton.mail;
in
{
  options.framework.programs.proton.mail = {
    enable = lib.mkEnableOption "install a ProtonMail wrapper";

    package = lib.mkOption {
      type = lib.types.package;
      description = "the wrapper app package";
      default = mkChromiumApp pkgs {
        appName = "proton-mail";
        configDirName = "proton";
        url = "https://mail.proton.me/u/0";

        icon = "${framework}/assets/icons/proton-mail.png";
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