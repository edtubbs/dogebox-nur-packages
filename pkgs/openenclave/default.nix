{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  dpkg ? pkgs.dpkg,
  autoPatchelfHook ? pkgs.autoPatchelfHook,
  openssl_1_1 ? pkgs.openssl_1_1,
  sgx-psw ? pkgs.sgx-psw or null,
  ...
}:

# OpenEnclave SDK packaged from the upstream Ubuntu 20.04 amd64 Debian
# release artifact published at
# https://github.com/openenclave/openenclave/releases.
#
# Building the SDK from source is the documented alternative to
# `apt install open-enclave` (see libdogecoin v0.1.5-dev `doc/enclaves.md`,
# section "Building OpenEnclave Libdogecoin Key Manager Enclave"), but
# building from source in pure Nix is impractical: the upstream tree
# vendors mbedtls, requires clang-11 plus the Intel SGX DCAP toolchain,
# and pulls in dozens of git submodules. The published `.deb` is the same
# artifact `apt install open-enclave` would install, so we unpack it and
# let `autoPatchelfHook` rewrite each binary's interpreter and RPATH to
# point at the Nix store.
#
# Intel SGX is x86 only, so this package is restricted to x86_64-linux.
# nixpkgs ships `sgx-psw` (PSW/runtime + AESM) and the `services.aesmd`
# NixOS module, but no SGX SDK, no Intel DCAP libs, and no OpenEnclave —
# hence this derivation. SGX runtime libraries (`libsgx_*`) come from
# `sgx-psw` when it is available.

stdenv.mkDerivation rec {
  pname = "openenclave";
  version = "0.19.13";

  src = fetchurl {
    url = "https://github.com/openenclave/openenclave/releases/download/v${version}/Ubuntu_2004_open-enclave_${version}_amd64.deb";
    hash = "sha256-25edFaPz3yL+R72aKtCgUakeNXku8Niw1oPBoAc+XM8=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  # `oesign` links against libcrypto.so.1.1 (openssl 1.1). The other tools
  # (`oeedger8r`, `oeutil`, `oeverify`, ...) only need the C/C++ runtime
  # which `stdenv.cc.cc.lib` provides on the autoPatchelf search path. The
  # SGX runtime libraries (`libsgx_*`) come from `sgx-psw`, and are
  # `propagatedBuildInputs` so consumers that link against `liboehost.a`
  # automatically inherit the SGX runtime closure.
  buildInputs = [
    openssl_1_1
    stdenv.cc.cc.lib
  ];

  propagatedBuildInputs = lib.optional (sgx-psw != null) sgx-psw;

  # Intel DCAP libraries (`libsgx_dcap_ql.so.1`, `libdcap_quoteprov.so.1`)
  # are not in nixpkgs; they are only needed at runtime for DCAP remote
  # attestation on real hardware, not for building/signing enclaves.
  # Consumers that need DCAP must provide them at runtime (e.g. via
  # LD_LIBRARY_PATH or by patchelf'ing the host binary against a separately
  # packaged sgx-dcap).
  autoPatchelfIgnoreMissingDeps = [
    "libsgx_dcap_ql.so.1"
    "libdcap_quoteprov.so.1"
  ] ++ lib.optionals (sgx-psw == null) [
    "libsgx_enclave_common.so.1"
    "libsgx_urts.so"
    "libsgx_urts.so.1"
    "libsgx_quote_ex.so.1"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r opt/openenclave/. "$out/"

    # Rewrite the convenience env-script to point at the Nix store layout.
    # Pups / consumers that source `share/openenclave/openenclaverc`
    # continue to work unmodified.
    if [ -f "$out/share/openenclave/openenclaverc" ]; then
      substituteInPlace "$out/share/openenclave/openenclaverc" \
        --replace-quiet "/opt/openenclave" "$out"
    fi

    runHook postInstall
  '';

  # The cmake package config (`openenclave-config.cmake`) is fully
  # relocatable: `PACKAGE_PREFIX_DIR` is derived from
  # `CMAKE_CURRENT_LIST_DIR`, so consumers using
  # `find_package(OpenEnclave CONFIG REQUIRED)` only need
  # `$out/lib/openenclave/cmake` on `CMAKE_PREFIX_PATH`.

  meta = with lib; {
    description = "Open Enclave SDK (Intel SGX), upstream Ubuntu 20.04 amd64 release";
    longDescription = ''
      OpenEnclave SDK provides headers, libraries, and tools (oeedger8r,
      oesign, oeutil, oeverify, ...) for building Intel SGX enclaves.
      This derivation unpacks the official upstream `.deb` release because
      nixpkgs does not ship OpenEnclave and a from-source build pulls in
      vendored mbedtls, clang-11 LVI mitigations, and the Intel SGX DCAP
      toolchain.
    '';
    homepage = "https://openenclave.io/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
