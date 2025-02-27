{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  optee-client ? pkgs.optee-client,
  optee-os-rockchip-rk3588 ? pkgs.optee-os-rockchip-rk3588,
  ...
}:

stdenv.mkDerivation rec {
  pname = "libdogecoin-optee";
  version = "0.1.4-dogebox-enclave";

  ############################################################
  # Source: libdogecoin repository with src/optee/host & src/optee/ta
  ############################################################
  src = fetchurl {
    url  = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-HLgDkMWjjxnfDmqIJ4d2Univ3W/6zMZbB9Pt8XETW6A=";
  };

  ############################################################
  # Build Inputs: Use the overridden libraries and OP-TEE packages
  ############################################################
  buildInputs = [
    optee-client.dev
    optee-client.lib
    optee-os-rockchip-rk3588.devkit
  ];

  ############################################################
  # No local library configure—only build host & TA code.
  ############################################################
  configurePhase = ''
    export HOME=$(pwd)
    make depends CFLAGS="-O0" HOST=aarch64-gnu-linux -j${stdenv.hostPlatform.jobs}
    ./autogen.sh
    LIBS="-levent_core" CFLAGS="-O0" ./configure --prefix=$pwd/depends/aarch64-linux-gnu/
  '';

  ############################################################
  # Build Phase:
  #  a) Build Host from src/optee/host
  #  b) Build TA from src/optee/ta
  ############################################################
  buildPhase = ''
    export HOME=$(pwd)
    make -j${stdenv.hostPlatform.jobs} install

    # --- Build Host ---
    cd src/optee/host
    make -j${stdenv.hostPlatform.jobs} \
      CXX=${stdenv.cc.cc} \
      LDFLAGS="
        -L${optee-client.lib}/lib
        -L$HOME/depends/aarch64-linux-gnu/lib
        -ldogecoin -lunistring
      " \
      CFLAGS="
        -I${optee-client.dev}/include
        -I$HOME/src/optee/ta/include
        -I$HOME/depends/aarch64-linux-gnu/include
        -I$HOME/depends/aarch64-linux-gnu/include/ykpers-1
        -I$HOME/depends/aarch64-linux-gnu/include/dogecoin
      "
    cd ../../..

    # --- Build TA ---
    cd src/optee/ta
    make -j${stdenv.hostPlatform.jobs} \
      PLATFORM=rockchip-rk3588 \
      LIBDIR=$HOME/depends/aarch64-linux-gnu/lib \
      LDFLAGS="
        -L$LIBDIR
        -ldogecoin -lunistring
      " \
      CFLAGS="
        -I$HOME/depends/aarch64-linux-gnu/include
        -I$HOME/depends/aarch64-linux-gnu/include/dogecoin
        -I${optee-os-rockchip-rk3588.devkit}/host_include
        -I${optee-os-rockchip-rk3588.devkit}/src
        -O0
      " \
      TA_DEV_KIT_DIR=${optee-os-rockchip-rk3588.devkit}
    cd ../../..
  '';

  ############################################################
  # Install Phase: Copy the host binary and TA into $out.
  ############################################################
  installPhase = ''
    mkdir -p $out/bin $out/ta
    if [ -f src/optee/host/libdogecoin_optee ]; then
      cp src/optee/host/libdogecoin_optee $out/bin/
    fi
    if [ -f src/optee/ta/62d95dc0-7fc2-4cb3-a7f3-c13ae4e633c4.ta ]; then
      cp src/optee/ta/62d95dc0-7fc2-4cb3-a7f3-c13ae4e633c4.ta $out/ta/
    fi
  '';

  meta = {
    description = ''
      Build libdogecoin-optee host (libdogecoin_optee) and TA 
      (62d95dc0-7fc2-4cb3-a7f3-c13ae4e633c4.ta) from the libdogecoin repo source,
      linking against pkgs.libdogecoin (overridden to -O0 with libunistring) and
      additional libraries (libusb1, yubikey, ykpers) also compiled with -O0,
      using OP-TEE devkit for TA build.
    '';
    homepage = "https://github.com/edtubbs/libdogecoin";
    license = lib.licenses.mit;
    platforms = [ "aarch64-linux" ];
  };
}

