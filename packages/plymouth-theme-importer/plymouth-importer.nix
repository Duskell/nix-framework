# BROKEN, add theme to the extra shas instead
{
  stdenv,
  lib,
  selected_themes ? [ ],
}:
let
  version = "1.0";
  src = builtins.path { path = ../../resources/plymouth; name = "local-plymouth-themes"; };
in
stdenv.mkDerivation {
  pname = "local-plymouth-themes";
  inherit version src selected_themes;

  passthru = {
    providedThemes = selected_themes;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes
    for theme in $selected_themes; do
      cp -r $src/$theme $out/share/plymouth/themes/$theme
    done
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
  '';

  meta = with lib; {
    description = "Plymouth boot themes from local flake";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
