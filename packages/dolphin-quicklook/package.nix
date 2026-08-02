# Copyright (c) 2026 Pir0c0pter0. All Rights Reserved.
{
  lib,
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  ninja,
  bash,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dolphin-quicklook";
  version = "1.0.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "dolphin";
    rev = "b12eada7126627c43e463b1c1fff191233485d00";
    hash = "sha256-KFu09HxM6exybczSuOnUDjudL1JuO5+5zU/xO1eUtM8=";
  };

  nativeBuildInputs = [
    ninja
    bash
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    kdePackages.kdoctools
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtdeclarative
    kcoreaddons
    ki18n
    kxmlgui
    baloo
    baloo-widgets
    knotifications
    kcolorscheme
    solid
    kparts
    kdoctools
    kio-extras
    knewstuff
    kfilemetadata
    kbookmarks
    ktextwidgets
    kuserfeedback
    kcodecs
    packagekit-qt
    kio
    kcmutils
    kwindowsystem
    kcompletion
    kcrash
    kdbusaddons
    kconfig
    kiconthemes
    qtmultimedia
    qtwebengine
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
  ];

  patches = [
    ./quicklook.patch
  ];

  meta = {
    description = "Patched version of KDE's Dolphin, with quick-look features.";
    homepage = "https://github.com/pir0c0pter0/dolphin-quicklook";
    license = lib.licenses.gpl2Plus;
    mainProgram = "dolphin";
  };
})
