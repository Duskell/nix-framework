final: prev: let
  scriptsDir = ./scripts;
  dirContents = builtins.readDir scriptsDir;
  allFiles = builtins.attrNames dirContents;
  scriptFiles =
    builtins.filter (
      file: (builtins.match ".*\\.nix$" file) != null
    )
    allFiles;

  autoScripts = builtins.listToAttrs (map (file: let
      len = builtins.stringLength file;
      pkgName = builtins.substring 0 (len - 4) file;
    in {
      name = pkgName;
      value = final.callPackage (scriptsDir + "/${file}") {};
    })
    scriptFiles);
in
  autoScripts
  // {
    gpu-screen-recorder = final.callPackage ./gpu-screen-recorder/package.nix {};
    gpu-screen-recorder-ui = final.callPackage ./gpu-screen-recorder-ui/package.nix {};
    gpu-screen-recorder-notification = final.callPackage ./gpu-screen-recorder-notification/package.nix {};
    vinyl-theme = final.callPackage ./vinyl-theme/package.nix {};
    plymouth-themes = final.callPackage ./plymouth-theme-importer/package.nix {};
    pear-desktop = final.callPackage ./pear-desktop/package.nix {};
  }
