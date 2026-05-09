{
  config,
  lib,
  pkgs,
  nixos-framework,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (nixos-framework.lib.webwrap) mkChromiumApp;
  cfg = config.nixos-framework.programs.proton.proton-mail;
in
{
  options.nixos-framework.programs.proton.proton-mail = {
    enable = lib.mkEnableOption "install a ProtonMail wrapper";

    package = lib.mkOption {
      type = lib.types.package;
      description = "the wrapper app package";
      default = mkChromiumApp pkgs {
        appName = "proton-mail";
        configDirName = "proton";
        url = "https://mail.proton.me/u/0";

        icon = "${./assets/proton-mail.png}";
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