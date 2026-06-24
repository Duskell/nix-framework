{
  stdenv,
  lib,
  libnotify,
  subversion,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "toggle-touchpad";
  version = "1.0";
  src = ./bash;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin

    cp toggle-touchpad.sh $out/bin/toggle-touchpad
    chmod +x $out/bin/toggle-touchpad

    patchShebangs $out/bin/toggle-touchpad

    wrapProgram $out/bin/toggle-touchpad \
      --prefix PATH : ${lib.makeBinPath [subversion libnotify]}
  '';
}
