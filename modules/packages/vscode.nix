{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos-framework.programs.dev.vscode;
  primaryUser = config.nixos-framework.core.primaryUser;
in
{
  options.nixos-framework.programs.dev.vscode = {
    enable = lib.mkEnableOption "install visual studio code";
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${primaryUser} =
      { config, ... }:
      {
        programs.vscode = {
          enable = true;

          profiles.default.userSettings = {
            "workbench.colorTheme" = "Thanatos";
            "workbench.iconTheme" = "material-icon-theme";
            "editor.fontFamily" = "JetBrains Mono";
            "editor.fontLigatures" = true;
            "editor.tabSize": 2;
            "git.enableSmartCommit" = true;
            "git.confirmSync" = false;
            "editor.tabSize" = 4;
            "intelephense.stubs" = [
              "apache"
              "bcmath"
              "bz2"
              "calendar"
              "com_dotnet"
              "Core"
              "ctype"
              "curl"
              "date"
              "dba"
              "dom"
              "enchant"
              "exif"
              "FFI"
              "fileinfo"
              "filter"
              "fpm"
              "ftp"
              "gd"
              "gettext"
              "gmp"
              "hash"
              "iconv"
              "imap"
              "intl"
              "json"
              "ldap"
              "libxml"
              "mbstring"
              "meta"
              "mysqli"
              "oci8"
              "odbc"
              "openssl"
              "pcntl"
              "pcre"
              "PDO"
              "pgsql"
              "Phar"
              "posix"
              "pspell"
              "random"
              "readline"
              "Reflection"
              "session"
              "shmop"
              "SimpleXML"
              "snmp"
              "soap"
              "sockets"
              "sodium"
              "SPL"
              "sqlite3"
              "standard"
              "superglobals"
              "sysvmsg"
              "sysvsem"
              "sysvshm"
              "tidy"
              "tokenizer"
              "uri"
              "xml"
              "xmlreader"
              "xmlrpc"
              "xmlwriter"
              "xsl"
              "Zend OPcache"
              "zip"
              "zlib"
              "wordpress"
            ];
          };

          profiles.default.extensions =
            with pkgs.vscode-extensions;
            [
              pkief.material-icon-theme
              ecmel.vscode-html-css
              ms-dotnettools.csharp
              ms-dotnettools.vscodeintellicode-csharp
              ritwickdey.liveserver
              ms-python.python
              mechatroner.rainbow-csv
              visualstudiotoolsforunity.vstuc
              bbenoist.nix
              bmewburn.vscode-intelephense-client

            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "theme-easy-eyes";
                publisher = "vvhg1";
                version = "1.2.1";
                hash = "sha256-t1ZAypr077IqJqA3mLgRgleqY/Q74VOkyrHjDvs/Bo8=";
              }
              {
                name = "nix-extension-pack";
                publisher = "pinage404";
                version = "3.0.0";
                hash = "sha256-cWXd6AlyxBroZF+cXZzzWZbYPDuOqwCZIK67cEP5sNk=";
              }
              {
                name = "better-nix-syntax";
                publisher = "jeff-hykin";
                version = "2.3.0";
                hash = "sha256-Zb4RFs2qkSMeQKkNXk4brrZBDiRK4e08taOOgdRWQEk=";
              }
              {
                name = "nix";
                publisher = "alvarosannas";
                version = "1.4.8";
                hash = "sha256-6ymqo2qOZolehS+AN4j8LM8Ksdt3Jux3GmNz+FYjkpw=";
              }
            ];
        };
      };
  };
}