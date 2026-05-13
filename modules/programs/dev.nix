# A collection of dev stuff that i didn't want to bother giving a separate file to.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption optional optionals;
  cfg = config.nixos-framework.programs.dev;
  primaryUser = config.nixos-framework.primaryUser;
in
{
  options.nixos-framework.programs.dev = {
    core.enable = mkEnableOption "install basic dev tools";
    android.enable = mkEnableOption "install Android Studio";
    unity.enable = mkEnableOption "install Unity Hub";
    node.enable = mkEnableOption "install NodeJS";
    postmarket.enable = mkEnableOption "install PostMarketOS bootstrap";
    devenv.enable = mkEnableOption "install Devenv";
  };

  config = {
      home-manager.users.${primaryUser}.home.packages =
        (optionals cfg.core.enable [
            pkgs.gcc
            pkgs.gnumake
            pkgs.jq
        ])
        ++ (optional cfg.android.enable pkgs.android-studio)
        ++ (optional cfg.node.enable pkgs.nodejs_24)
        ++ (optional cfg.unity.enable pkgs.unityhub)
        ++ (optional cfg.devenv.enable pkgs.devenv)
        ++ (optional cfg.postmarket.enable pkgs.pmbootstrap);
    };
}