final: prev: {

  gpu-screen-recorder = prev.callPackage ./gpu-screen-recorder/package.nix { };
  gpu-screen-recorder-ui = prev.callPackage ./gpu-screen-recorder-ui/package.nix { };
  gpu-screen-recorder-notification = prev.callPackage ./gpu-screen-recorder-notification/package.nix { };
  vinyl-theme = prev.callPackage ./vinyl-theme/package.nix { };
  plymouth-themes = prev.callPackage ./plymouth-theme-importer/package.nix { };

}