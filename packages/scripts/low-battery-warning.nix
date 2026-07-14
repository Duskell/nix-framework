{
  stdenv,
  lib,
  makeWrapper,
  pkgs,
}: let
  name = "low-battery-warning";

  runtimeInputs = with pkgs; [
    acpi
    libnotify
  ];
in
  stdenv.mkDerivation {
    pname = name;
    version = "1.0";
    src = ./bash;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/bin

      cp ${name}.sh $out/bin/${name}
      chmod +x $out/bin/${name}

      patchShebangs $out/bin/${name}

      wrapProgram $out/bin/${name} \
        --prefix PATH : ${lib.makeBinPath runtimeInputs}
    '';
  }
