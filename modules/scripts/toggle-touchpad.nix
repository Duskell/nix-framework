{
  stdenv,
  lib,
  bash,
  subversion,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "toggle-touchpad";
  version = "1.0";
  src = ./bash;
  buildInputs = [bash subversion];
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out/bin
    cp toggle-touchpad.sh $out/bin/toggle-touchpad
    chmod +x $out/bin/toggle-touchpad
    wrapProgram $out/bin/toggle-touchpad \
      --prefix PATH : ${lib.makeBinPath [bash subversion]}
  '';
}
