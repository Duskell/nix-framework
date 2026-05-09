# Source: https://github.com/TLATER/nix-webapps/blob/1bb9ee8e3f428575c1c6898ae7af8d96416d696a/imports/lib.nix
{ nixpkgs, ... }@inputs:
let
  lib = nixpkgs.lib;
in
{

  mkChromiumApp =
    pkgs:
    {
      appName,
      url,

      # Chrome options.
      profile ? "Default",
      configDirName ? appName,

      # Desktop entry options.
      icon ? appName,
      desktopName ? appName,
      genericName ? appName,
      categories ? [ ],
      wmClass ? appName,
    }@args:
    (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "chromium-app-${appName}";
      version = "1.0.0";

      buildInputs = [ pkgs.chromium ];

      nativeBuildInputs = [
        pkgs.makeBinaryWrapper
        pkgs.copyDesktopItems
      ];

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        makeWrapper ${lib.getExe (pkgs.chromium.override { enableWideVine = true; })} $out/bin/${appName} \
          --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WebUIDarkMode" \
          --add-flags "--ozone-platform-hint=auto" \
          --add-flags "--profile-directory=${profile}" \
          --add-flags "--disable-sync-preferences" \
          --add-flags "--user-data-dir=\$XDG_CONFIG_HOME/chromium-${configDirName}" \
          --add-flags ${lib.escapeShellArg "--app=${url}"}
        runHook postInstall
      '';

      desktopItems = [
        (pkgs.makeDesktopItem {
          name = appName;
          exec = appName;
          icon = icon;
          desktopName = desktopName;
          genericName = genericName;
          categories = categories;
          startupWMClass = wmClass;
        })
      ];
    })).overrideAttrs
      args;

}