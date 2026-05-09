{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos-framework.programs.starship;
  primaryUser = config.nixos-framework.core.primaryUser;
in
{
  options.nixos-framework.programs.starship = {
    enable = lib.mkEnableOption "Starship shell prompt";
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${primaryUser} =
      { config, ... }:
      {
        programs.starship = {
          enable = true;
          settings = {
            add_newline = true;
            command_timeout = 1300;
            scan_timeout = 50;

            format =
              "[ $hostname ](bg:color_pale_red fg:color_fg0)"
              + "[](bg:color_yellow fg:color_pale_red)"
              + "$directory"
              + "[](bg:color_purple fg:color_yellow)"
              + "$git_branch$git_status"
              + "[](bg:color_blue fg:color_purple)"
              + "$c$cpp$rust$golang$nodejs$php$java$kotlin$haskell$python"
              + "[](bg:color_bg3 fg:color_blue)"
              + "$docker_context$conda$pixi"
              + "[](bg:color_bg1 fg:color_bg3)"
              + "$time"
              + "[ ](fg:color_bg1)"
              + "$line_break$character";

            palette = "stylix";
            palettes.stylix = {
              color_fg0 = "#${config.lib.stylix.colors.base01}";
              color_bg1 = "#${config.lib.stylix.colors.base02}";
              color_bg3 = "#${config.lib.stylix.colors.base03}";
              color_blue = "#${config.lib.stylix.colors.base0C}";
              color_purple = "#${config.lib.stylix.colors.base0E}";
              color_pale_orange = "#${config.lib.stylix.colors.base0B}";
              color_pale_red = "#${config.lib.stylix.colors.base0D}";
              color_dark_red = "#7A1531";
              color_red = "#${config.lib.stylix.colors.base08}";
              color_yellow = "#${config.lib.stylix.colors.base0F}";
            };

            hostname = {
              ssh_only = false;
              disabled = false;
              format = "[$hostname]($style)";
              style = "bg:color_pale_red fg:color_fg0";
            };

            directory = {
              style = "fg:color_fg0 bg:color_yellow";
              format = "[ $path ]($style)";
              truncation_length = 3;
              truncation_symbol = "…/";
              substitutions = {
                Documents = "󰈙 ";
                Downloads = " ";
                Music = "󰝚 ";
                Pictures = " ";
                Developer = "󰲋 ";
              };
            };

            git_branch = {
              symbol = "";
              style = "bg:color_purple";
              format = "[[ $symbol $branch ](fg:color_fg0 bg:color_purple)]($style)";
            };

            git_status = {
              style = "bg:color_purple";
              format = "[[ \\[ $all_status$ahead_behind \\] ](fg:color_dark_red bg:color_purple)]($style)";
            };

            nodejs = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            c = {
              symbol = " ";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            cpp = {
              symbol = " ";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            rust = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            golang = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            php = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            java = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            kotlin = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            haskell = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };
            python = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            docker_context = {
              symbol = "";
              style = "bg:color_bg3";
              format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
            };

            conda = {
              style = "bg:color_bg3";
              format = "[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)";
            };

            pixi = {
              style = "bg:color_bg3";
              format = "[[ $symbol( $version)( $environment) ](fg:color_fg0 bg:color_bg3)]($style)";
            };

            time = {
              disabled = false;
              time_format = "%R";
              style = "bg:color_bg1";
              format = "[[  $time ](fg:color_pale_red bg:color_bg1)]($style)";
            };

            line_break = {
              disabled = false;
            };
          };
        };
      };
  };
}
