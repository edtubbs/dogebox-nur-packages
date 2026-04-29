{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  # OpenEnclave SDK is not in nixpkgs; we ship our own derivation under
  # `pkgs/openenclave` and inject it from `default.nix`. It is only used by
  # the `libdogecoin-openenclave-*` derivations below, which are gated to
  # x86_64-linux (Intel SGX is x86 only).
  openenclave ? pkgs.callPackage ../openenclave {},
  ...
}:

let
  # Static libevent build used by the OpenEnclave host/enclave cmake builds,
  # which link against `libevent.a` / `libevent_core.a` directly (see upstream
  # `src/openenclave/{host,enclave}/CMakeLists.txt`). Stock nixpkgs libevent is
  # shared-only, so we override it to produce static archives.
  libevent-static = pkgs.libevent.overrideAttrs (old: {
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--disable-shared"
      "--enable-static"
    ];
  });

  libdogecoin-optee-ta-libs = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-ta-libs";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
      make \
        LDFLAGS="-L${libdogecoin-optee-host-libs}/lib -ldogecoin" \
        CFLAGS="-I${libdogecoin-optee-host-libs}/include -I${libdogecoin-optee-host-libs}/include/dogecoin -I${pkgs.optee-client.dev}/include -I${pkgs.yubikey-personalization}/include/ykpers-1 -I$HOME/src/optee/ta/include"
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp optee_libdogecoin $out/bin/
      chmod 777 $out/bin/optee_libdogecoin
    '';
  };

  libdogecoin-openenclave-enclave-libs = stdenv.mkDerivation rec {
    pname = "libdogecoin-openenclave-enclave-libs";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
      pkgs.libevent.dev
      openenclave
    ];

    configurePhase = ''
      export HOME=$(pwd)
      export CFLAGS="$CFLAGS -Wp,-D_FORTIFY_SOURCE=0"
      export ac_cv_prog_cc_works=yes
      ./autogen.sh
      LIBS="-levent_core -levent_pthreads" \
        ./configure --prefix=$out --enable-static --disable-shared \
          --enable-openenclave --enable-test-passwd \
          --build=${stdenv.buildPlatform.config} \
          --host=${stdenv.hostPlatform.config}
    '';

    buildPhase = ''
      export HOME=$(pwd)
      make
    '';
  };

  libdogecoin-openenclave-host-libs = stdenv.mkDerivation rec {
    pname = "libdogecoin-openenclave-host-libs";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
    ];

    configurePhase = ''
      export HOME=$(pwd)
      export ac_cv_prog_cc_works=yes
      ./autogen.sh
      LIBS="-levent_core -levent_pthreads" \
        ./configure --prefix=$out --enable-static --disable-shared \
          --enable-test-passwd \
          --build=${stdenv.buildPlatform.config} \
          --host=${stdenv.hostPlatform.config}
    '';

    buildPhase = ''
      export HOME=$(pwd)
      make
    '';
  };

  libdogecoin-openenclave-enclave = stdenv.mkDerivation rec {
    pname = "libdogecoin-openenclave-enclave";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
    };
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.pkg-config
      pkgs.openssl
    ];
    buildInputs = [
      openenclave
      libdogecoin-openenclave-enclave-libs
      pkgs.libevent
      pkgs.libevent.dev
    ];

    # Mirror the directory layout the upstream CMakeLists.txt expects for the
    # enclave build (see docs/enclaves.md, "Building OpenEnclave Libdogecoin
    # Key Manager Enclave"): libdogecoin enclave libs under
    # `depends/x86_64-pc-linux-gnu` and libevent under `src/libevent/build`.
    configurePhase = ''
      export HOME=$(pwd)
      mkdir -p depends/x86_64-pc-linux-gnu/include depends/x86_64-pc-linux-gnu/lib
      cp -r ${libdogecoin-openenclave-enclave-libs}/include/* depends/x86_64-pc-linux-gnu/include/
      cp -r ${libdogecoin-openenclave-enclave-libs}/lib/* depends/x86_64-pc-linux-gnu/lib/
      mkdir -p src/libevent/build/include src/libevent/build/lib
      cp -r ${pkgs.libevent.dev}/include/* src/libevent/build/include/
      cp ${libevent-static}/lib/libevent*.a src/libevent/build/lib/
      mkdir -p src/openenclave/build
      cd src/openenclave/build
      cmake .. -DCMAKE_BUILD_TYPE=Release
    '';

    buildPhase = ''
      export HOME=$(pwd)
      cd $HOME/src/openenclave/build
      make sign
    '';

    installPhase = ''
      mkdir -p $out/enclave
      cp enclave/enclave.signed $out/enclave/
    '';

    meta = {
      description = "libdogecoin OpenEnclave (Intel SGX) signed enclave";
      platforms = [ "x86_64-linux" ];
    };
  };

  libdogecoin-openenclave-host = stdenv.mkDerivation rec {
    pname = "libdogecoin-openenclave-host";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
    };
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.pkg-config
      pkgs.openssl
      pkgs.makeWrapper
    ];
    buildInputs = [
      openenclave
      libdogecoin-openenclave-host-libs
      pkgs.libevent
      pkgs.libevent.dev
      pkgs.yubikey-personalization
      pkgs.libusb1
      pkgs.libyubikey
    ];

    # The upstream CMakeLists references libdogecoin/libevent under
    # `depends/x86_64-pc-linux-gnu/host` and `src/libevent/build`. We
    # materialise that layout from the Nix-built dependencies so cmake can
    # locate the static archives and headers.
    configurePhase = ''
      export HOME=$(pwd)
      mkdir -p depends/x86_64-pc-linux-gnu/host/include depends/x86_64-pc-linux-gnu/host/lib
      cp -r ${libdogecoin-openenclave-host-libs}/include/* depends/x86_64-pc-linux-gnu/host/include/
      cp -r ${libdogecoin-openenclave-host-libs}/lib/* depends/x86_64-pc-linux-gnu/host/lib/
      mkdir -p src/libevent/build/include src/libevent/build/lib
      cp -r ${pkgs.libevent.dev}/include/* src/libevent/build/include/
      cp ${libevent-static}/lib/libevent*.a src/libevent/build/lib/
      mkdir -p src/openenclave/build
      cd src/openenclave/build
      cmake .. -DCMAKE_BUILD_TYPE=Release
    '';

    buildPhase = ''
      export HOME=$(pwd)
      cd $HOME/src/openenclave/build
      make host
    '';

    # Install the raw host binary and a wrapper named `openenclave_libdogecoin`
    # that points at the signed enclave produced by the enclave derivation.
    # Pups (e.g. spv_enclave) can invoke this wrapper directly, mirroring how
    # the optee `optee_libdogecoin` binary is used on aarch64.
    installPhase = ''
      mkdir -p $out/bin $out/libexec/openenclave_libdogecoin
      cp host/host $out/libexec/openenclave_libdogecoin/host
      chmod 755 $out/libexec/openenclave_libdogecoin/host
      ln -s ${libdogecoin-openenclave-enclave}/enclave/enclave.signed \
        $out/libexec/openenclave_libdogecoin/enclave.signed
      makeWrapper $out/libexec/openenclave_libdogecoin/host \
        $out/bin/openenclave_libdogecoin \
        --add-flags $out/libexec/openenclave_libdogecoin/enclave.signed
    '';

    passthru = {
      enclave = libdogecoin-openenclave-enclave;
    };

    meta = {
      description = "libdogecoin OpenEnclave (Intel SGX) host with bundled signed enclave";
      platforms = [ "x86_64-linux" ];
    };
  };

  libdogecoin-optee-ta = stdenv.mkDerivation rec {
    pname = "libdogecoin-optee-ta";
    version = "0.1.5-pre";
    src = fetchurl {
      url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
  version = "0.1.5-pre";

  src = fetchurl {
    url = "https://github.com/dogecoinfoundation/libdogecoin/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-oQMR0EzzRcsfZ3DoKnESXanEjm6dk2X+7zFhL+Ae6cs=";
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
  inherit libdogecoin-openenclave-enclave-libs libdogecoin-openenclave-host-libs libdogecoin-openenclave-host libdogecoin-openenclave-enclave;
}
