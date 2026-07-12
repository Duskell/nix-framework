{
  stdenv,
  lib,
  makeWrapper,
  playerctl,
  gnugrep,
  coreutils,
}:
stdenv.mkDerivation {
  pname = "polybar-floating-ytm";
  version = "1.0";
  src = ./bash;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin

    cp polybar-floating-ytm.sh $out/bin/polybar-floating-ytm
    chmod +x $out/bin/polybar-floating-ytm

    patchShebangs $out/bin/polybar-floating-ytm

    wrapProgram $out/bin/polybar-floating-ytm \
      --prefix PATH : ${lib.makeBinPath [playerctl gnugrep coreutils]}
  '';
}
