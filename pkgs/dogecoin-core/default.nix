{
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  lib ? pkgs.lib,
  disableWallet ? false,
  disableGUI ? false,
  disableTests ? false,
  ...
}:

stdenv.mkDerivation rec {
  pname = "dogecoin-core";
  version = "1.14.8";

  src = fetchurl {
    url = "https://github.com/dogecoin/dogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-+I3EiFNfArmAEsg6gkAC0Ief0nlkQ8Yhjf1keq7Hz2E=";
  };

  configureFlags = [
    "--with-incompatible-bdb"
    "--with-boost-libdir=${pkgs.boost}/lib"
  ]
  ++ lib.optional disableWallet "--disable-wallet"
  ++ lib.optional disableGUI "--with-gui=no"
  ++ lib.optional disableTests "--disable-tests";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.autoreconfHook
    pkgs.openssl
    pkgs.db5
    pkgs.util-linux
    pkgs.boost
    pkgs.zlib
    pkgs.libevent
    pkgs.protobuf
    pkgs.qrencode
  ];

  meta = with lib; {
    description = "Allows anyone to operate a node in the Dogecoin blockchain networks";
    homepage = "https://dogecoin.com";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
