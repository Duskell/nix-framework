{
  stdenv,
  lib,
  bash,
  subversion,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "toogle-touchpad";
  version = "1.0";
  src = ./bash;
  buildInputs = [bash subversion];
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out/bin
    cp toggle-touchpad.sh $out/bin/toggle-touchpad.sh
    wrapProgram $out/bin/toggle-touchpad.sh \
      --prefix PATH : ${lib.makeBinPath [bash subversion]}
  '';
}
