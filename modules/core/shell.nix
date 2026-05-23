{
  inputs,
  config,
  lib,
  framework,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption;
  shell = config.framework.core.shell;
  primaryUser = config.framework.primaryUser;
in {
  options.framework.core.shell = mkOption {
    type = types.enum ["bash" "zsh"];
    default = "bash";
    description = "the shell to use";
  };

  config = {
    programs.${shell}.enable = true;

    users.users.${primaryUser}.shell =
      if shell == "zsh"
      then pkgs.zsh
      else pkgs.bash;

    home-manager.users.${config.framework.primaryUser}.programs = {
      bash = mkIf (shell == "bash") {
        enable = true;
        initExtra = ''
          if [ -f "$HOME/.profile" ]; then
            . "$HOME/.profile"
          fi
        '';
      };

      zsh = mkIf (shell == "zsh") {
        enable = true;
        initExtra = ''
          if [ -f "$HOME/.profile" ]; then
            source "$HOME/.profile"
          fi
        '';
      };
    };
  };
}
