final: prev: {

  gpu-screen-recorder = final.callPackage ./gpu-screen-recorder/package.nix { };
  gpu-screen-recorder-ui = final.callPackage ./gpu-screen-recorder-ui/package.nix { };
  gpu-screen-recorder-notification = final.callPackage ./gpu-screen-recorder-notification/package.nix { };
  vinyl-theme = final.callPackage ./vinyl-theme/package.nix { };
  plymouth-themes = final.callPackage ./plymouth-theme-importer/package.nix { };

}