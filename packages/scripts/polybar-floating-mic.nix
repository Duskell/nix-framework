{
  stdenv,
  lib,
  makeWrapper,
  coreutils,
  gnugrep,
  gawk,
  pulseaudio,
}:
stdenv.mkDerivation {
  pname = "polybar-floating-mic";
  version = "1.0";
  src = ./bash;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin

    cp polybar-floating-mic.sh $out/bin/polybar-floating-mic
    chmod +x $out/bin/polybar-floating-mic

    patchShebangs $out/bin/polybar-floating-mic

    wrapProgram $out/bin/polybar-floating-mic \
      --prefix PATH : ${lib.makeBinPath [coreutils gnugrep gawk pulseaudio]}
  '';
}
