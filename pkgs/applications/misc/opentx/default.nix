{ stdenv, mkDerivation, fetchFromGitHub
, cmake, gcc-arm-embedded, python3Packages
, qtbase, qtmultimedia, qttranslations, SDL, gtest
, dfu-util, avrdude
}:

mkDerivation rec {
  pname = "opentx";
  version = "2.3.5";

  src = fetchFromGitHub {
    owner = "opentx";
    repo = "opentx";
    rev = version;
    sha256 = "18iv3c74y9fpp1045s2l7l2dqfn9riyagrwmfwp2mmf2ccsrwz2g";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake gcc-arm-embedded python3Packages.pillow ];

  buildInputs = [ qtbase qtmultimedia qttranslations SDL ];

  postPatch = ''
    sed -i companion/src/burnconfigdialog.cpp \
      -e 's|/usr/.*bin/dfu-util|${dfu-util}/bin/dfu-util|' \
      -e 's|/usr/.*bin/avrdude|${avrdude}/bin/avrdude|'
  '';

  cmakeFlags = [
    "-DGTEST_ROOT=${gtest.src}/googletest"
    "-DQT_TRANSLATIONS_DIR=${qttranslations}/translations"
    # XXX I would prefer to include these here, though we will need to file a bug upstream to get that changed.
    #"-DDFU_UTIL_PATH=${dfu-util}/bin/dfu-util"
    #"-DAVRDUDE_PATH=${avrdude}/bin/avrdude"
  ];

  meta = with stdenv.lib; {
    description = "OpenTX Companion transmitter support software";
    longDescription = ''
      OpenTX Companion is used for many different tasks like loading OpenTX
      firmware to the radio, backing up model settings, editing settings and
      running radio simulators.
    '';
    homepage = "https://www.open-tx.org/";
    license = licenses.gpl2;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ elitak lopsided98 ];
  };

}
