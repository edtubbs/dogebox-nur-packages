{ lib, pkgs, stdenv, fetchurl, ... }:

stdenv.mkDerivation {
  pname = "libdogecoin";
  version = "0.1.3";

  src = fetchurl {
    url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-KCzeeFpaAWSesdJc3uW4c7adYZk3PZtIKh9PND2Dul4=";
  };

  configurePhase = ''
    export HOME=$(pwd)
    ./autogen.sh
    ./configure
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sendtx spvnode such $out/bin
    cp -rv contrib $out/contrib
    cp -rv doc     $out/doc
    cp -rv include $out/include
    cp -rv .libs   $out/lib
    rm $out/lib/libdogecoin.la
    cp libdogecoin.la $out/lib
  '';

  buildInputs = [
    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
    pkgs.libevent
    pkgs.libunistring
  ];

  meta = with lib; {
    description = "A clean C library of Dogecoin building blocks";
    homepage = "https://github.com/dogecoinfoundation/libdogecoin";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
