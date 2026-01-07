{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  ...
}:

let
  libdogecoin-optee-ta-libs = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-ta-libs";
    version = "0.1.5-pre-snapshot-optee";
    src = fetchurl {
      url = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-O6wWjcHQ1/9lRUs/XikkirbmAl9aap8A0Ace75oH26U=";
    };

    nativeBuildInputs = [
      pkgs.autoconf
      pkgs.automake
      pkgs.libtool
      pkgs.curl
      pkgs.pkg-config
    ];
    buildInputs = [
      (pkgs.libunistring.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libevent.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libyubikey.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libusb1.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.yubikey-personalization.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "--with-backend=libusb-1.0"
        ];
      }))
      pkgs.libevent.dev
      pkgs.optee-client.dev
      pkgs.optee-client.lib
    ];

    configurePhase = ''
      export HOME=$(pwd)
      export CFLAGS="$CFLAGS -Wp,-D_FORTIFY_SOURCE=0"
      export ac_cv_prog_cc_works=yes
      ./autogen.sh
      # Force -D_FORTIFY_SOURCE=0 for the TA libs to avoid __chk references
      LIBS="-levent_core -levent_pthreads" \
        ./configure --prefix=$out --enable-static --disable-shared --enable-optee \
          --build=${stdenv.buildPlatform.config} \
          --host=${stdenv.hostPlatform.config}
    '';

    buildPhase = ''
      export HOME=$(pwd)
      make
    '';
  };

  libdogecoin-optee-host-libs = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-host-libs";
    version = "0.1.5-pre-snapshot-optee";
    src = fetchurl {
      url = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-O6wWjcHQ1/9lRUs/XikkirbmAl9aap8A0Ace75oH26U=";
    };

    nativeBuildInputs = [
      pkgs.autoconf
      pkgs.automake
      pkgs.libtool
      pkgs.curl
      pkgs.pkg-config
    ];
    buildInputs = [
      (pkgs.libunistring.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libevent.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libyubikey.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.libusb1.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
        ];
      }))
      (pkgs.yubikey-personalization.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "--with-backend=libusb-1.0"
        ];
      }))
      pkgs.libevent.dev
      pkgs.optee-client.dev
      pkgs.optee-client.lib
    ];

    configurePhase = ''
      export HOME=$(pwd)
      export ac_cv_prog_cc_works=yes
      ./autogen.sh
      LIBS="-levent_core -levent_pthreads" \
        ./configure --prefix=$out --enable-static --disable-shared \
          --build=${stdenv.buildPlatform.config} \
          --host=${stdenv.hostPlatform.config}
    '';

    buildPhase = ''
      export HOME=$(pwd)
      make
    '';
  };

  libdogecoin-optee-host = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-host";
    version = "0.1.5-pre-snapshot-optee";
    src = fetchurl {
      url = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-O6wWjcHQ1/9lRUs/XikkirbmAl9aap8A0Ace75oH26U=";
    };
    nativeBuildInputs = [
      pkgs.autoconf
      pkgs.automake
      pkgs.libtool
      pkgs.gcc
      pkgs.curl
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.optee-client.dev
      pkgs.optee-client.lib
      libdogecoin-optee-host-libs
      pkgs.yubikey-personalization
      pkgs.libusb1
      pkgs.libyubikey
    ];
    buildPhase = ''
      export HOME=$(pwd)
      cd src/optee/host
      $CC \
        -std=gnu11 -D_GNU_SOURCE \
        -Wall \
        -I../ta/include -I./include \
        -I${libdogecoin-optee-host-libs}/include \
        -I${libdogecoin-optee-host-libs}/include/dogecoin \
        -I${pkgs.optee-client.dev}/include \
        -I${pkgs.yubikey-personalization}/include/ykpers-1 \
        -I${pkgs.libusb1.dev or pkgs.libusb1}/include/libusb-1.0 \
        -I${pkgs.libyubikey}/include \
        main.c -o optee_libdogecoin \
        -L${libdogecoin-optee-host-libs}/lib \
        -L${pkgs.optee-client.lib}/lib \
        -ldogecoin -lykpers-1 -lyubikey -lusb-1.0 -lteec
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp optee_libdogecoin $out/bin/
      chmod 777 $out/bin/optee_libdogecoin
    '';
  };

  libdogecoin-optee-ta = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-ta";
    version = "0.1.5-pre-snapshot-optee";
    src = fetchurl {
      url = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-O6wWjcHQ1/9lRUs/XikkirbmAl9aap8A0Ace75oH26U=";
    };
    nativeBuildInputs = [
      pkgs.autoconf
      pkgs.automake
      pkgs.libtool
      pkgs.curl
      pkgs.pkg-config
      pkgs.python3
      pkgs.python3Packages.cryptography
    ];
    buildInputs = [
      (pkgs.libunistring.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "CFLAGS=-Wp,-D_FORTIFY_SOURCE=0"
        ];
      }))
      (pkgs.libevent.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "CFLAGS=-Wp,-D_FORTIFY_SOURCE=0"
        ];
      }))
      (pkgs.libyubikey.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "CFLAGS=-Wp,-D_FORTIFY_SOURCE=0"
        ];
      }))
      (pkgs.libusb1.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "CFLAGS=-Wp,-D_FORTIFY_SOURCE=0"
        ];
      }))
      (pkgs.yubikey-personalization.overrideAttrs (old: {
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--disable-shared"
          "--enable-static"
          "--with-backend=libusb-1.0"
          "CFLAGS=-Wp,-D_FORTIFY_SOURCE=0"
        ];
      }))
      pkgs.optee-client.dev
      pkgs.optee-client.lib
      pkgs.optee-os-rockchip-rk3588
      pkgs.optee-os-rockchip-rk3588.devkit
      libdogecoin-optee-ta-libs
    ];
    buildPhase = ''
      export HOME=$(pwd)
      cd src/optee/ta
      make \
        PLATFORM=rockchip-rk3588 \
        LIBDIR="${libdogecoin-optee-ta-libs}/lib" \
        LDFLAGS="-L${libdogecoin-optee-ta-libs}/lib -ldogecoin -lunistring" \
        CFLAGS="-I${libdogecoin-optee-ta-libs}/include -I${libdogecoin-optee-ta-libs}/include/dogecoin" \
        TA_DEV_KIT_DIR=${pkgs.optee-os-rockchip-rk3588.devkit}
    '';
    installPhase = ''
      mkdir -p $out/ta
      cp 62d95dc0-7fc2-4cb3-a7f3-c13ae4e633c4.ta $out/ta/
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "libdogecoin";
  version = "0.1.5-pre-snapshot-optee";

  src = fetchurl {
    url = "https://github.com/edtubbs/libdogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-O6wWjcHQ1/9lRUs/XikkirbmAl9aap8A0Ace75oH26U=";
  };

  configurePhase = ''
    export HOME=$(pwd)
    ./autogen.sh
    LIBS="-levent_core" ./configure
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
} // {
  inherit libdogecoin-optee-ta-libs libdogecoin-optee-host-libs libdogecoin-optee-host libdogecoin-optee-ta;
}
