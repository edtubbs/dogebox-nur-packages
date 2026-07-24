# Dogecoin Core with the dumptxoutset/loadtxoutset backport, built from
# the edtubbs/dogecoin branch copilot/backport-dumptxoutset-loadtxoutset
# (pinned by commit). Used by the core pup to produce D1 UTXO snapshots
# (utxo.dat) for the D2 chainstate handoff.
{
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  lib ? pkgs.lib,
  disableWallet ? false,
  disableGUI ? true,
  disableTests ? true,
  enableZMQ ? false,
  ...
}:

let
  boost_1_63_0 = stdenv.mkDerivation rec {
    pname = "boost";
    version = "1.63.0";

    src = pkgs.fetchurl {
      url = "mirror://sourceforge/boost/boost_1_63_0.tar.bz2";
      sha256 = "beae2529f759f6b3bf3f4969a19c2e9d6f0c503edcb2de4a61d1428519fcb3b0";
    };

    nativeBuildInputs = [ pkgs.bzip2 pkgs.perl pkgs.which pkgs.boost-build ];
    buildInputs = [ pkgs.zlib ]
      # Only add GCC explicitly on Linux — on Darwin use clang from stdenv
      ++ lib.optionals stdenv.hostPlatform.isLinux [ pkgs.gcc13 ];

    configurePhase = ''
      ./bootstrap.sh \
        --with-toolset=${if stdenv.hostPlatform.isDarwin then "clang" else "gcc"} \
        --without-icu --with-bjam=b2 \
        --with-libraries=chrono,filesystem,program_options,system,thread,test
    '';
    buildPhase     = ''b2 -d0 -j''${NIX_BUILD_CORES:-1} threading=multi link=static runtime-link=shared address-model=64 stage cxxflags="-std=c++11"'';
    installPhase   = ''b2 -d0 threading=multi link=static runtime-link=shared address-model=64 install --prefix="$out" cxxflags="-std=c++11"'';
  };
in
stdenv.mkDerivation rec {
  pname = "dogecoin-core-backport";
  # 1.14.99 development tree (post-1.14.9) with snapshot RPC backports.
  upstreamVersion = "1.14.99";
  derivationVersion = "v1";

  version = "${upstreamVersion}-${derivationVersion}";

  # Pinned tip of copilot/backport-dumptxoutset-loadtxoutset.
  src = fetchFromGitHub {
    owner = "edtubbs";
    repo = "dogecoin";
    rev = "f724aa8abe00f9a8c1fa8faa162b2b5592c2536e";
    hash = "sha256-xOH7PGHDOyDdDCeH8QnlDb8WC7whLCizd1xTLfUtUkM=";
  };

  configureFlags = [
    "--with-incompatible-bdb"
    "--with-boost-libdir=${boost_1_63_0}/lib"
  ]
  ++ lib.optional disableWallet "--disable-wallet"
  ++ lib.optional disableGUI "--with-gui=no"
  ++ lib.optional disableTests "--disable-tests";

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.autoreconfHook
  ];

  buildInputs = [
    pkgs.openssl
    pkgs.db5
    pkgs.util-linux
    boost_1_63_0
    pkgs.zlib
    pkgs.libevent
    pkgs.protobuf
    pkgs.qrencode
  ] ++ lib.optional enableZMQ [
    pkgs.zeromq
  ];

  meta = with lib; {
    description = "Dogecoin Core with dumptxoutset/loadtxoutset backport for D1->D2 snapshot handoff";
    homepage = "https://github.com/edtubbs/dogecoin/tree/copilot/backport-dumptxoutset-loadtxoutset";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
