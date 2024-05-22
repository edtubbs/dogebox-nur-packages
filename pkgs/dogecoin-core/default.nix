{ pkgs, stdenv, fetchurl, lib, ... }:

stdenv.mkDerivation rec {
  pname = "dogecoin-core";
  version = "1.14.7";

  src = fetchurl {
    url = "https://github.com/dogecoin/dogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-x0fCXGTb8pMa5vGKKkLlKXrTvj8qFX9X6KbiaHpnmF0=";
  };

  configureFlags = [
    "--with-incompatible-bdb"
    "--with-boost-libdir=${pkgs.boost}/lib"
  ];

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
    pkgs.miniupnpc
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
