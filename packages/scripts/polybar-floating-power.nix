{
  stdenv,
  lib,
  makeWrapper,
  coreutils,
  procps,
  gnused,
  vicinae,
}:
stdenv.mkDerivation {
  pname = "polybar-floating-power";
  version = "1.0";
  src = ./bash;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin

    cp polybar-floating-power.sh $out/bin/polybar-floating-power
    chmod +x $out/bin/polybar-floating-power

    patchShebangs $out/bin/polybar-floating-power

    wrapProgram $out/bin/polybar-floating-power \
      --prefix PATH : ${lib.makeBinPath [coreutils procps gnused vicinae]}
  '';
}
