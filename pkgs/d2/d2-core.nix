{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  rustPlatform ? pkgs.rustPlatform,
  ...
}:

let
  source = import ./source.nix { inherit pkgs; };
in
rustPlatform.buildRustPackage {
  pname = "d2-core";
  inherit (source) version src;

  # d2core-backend is now a Rust crate producing a cdylib/staticlib
  # behind the 26-fn d2core.h C ABI consumed by Flutter dart:ffi
  # (d2-core/backend/Cargo.toml). It depends on ../../libd2/crates/d2
  # and ../../d2-node/crates/d2-rpc-types by path, so the whole tree
  # must stay unpacked.
  cargoRoot = "d2-core/backend";
  buildAndTestSubdir = "d2-core/backend";

  # ./Cargo.lock.d2-core must be kept in sync with
  # d2-core/backend/Cargo.lock from the pinned d2 revision:
  #   cp <d2-checkout>/d2-core/backend/Cargo.lock pkgs/d2/Cargo.lock.d2-core
  cargoLock = source.mkCargoLock ./Cargo.lock.d2-core;

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.perl
  ];

  buildInputs = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # buildRustPackage's installPhase only installs binaries; this crate
  # is a library, so install the cdylib/staticlib and the checked-in
  # cbindgen header explicitly.
  postInstall = ''
    mkdir -p $out/lib $out/include
    find target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release \
      -maxdepth 1 -name 'libd2core.*' -exec install -Dm755 {} $out/lib/ \;
    if [ -f d2-core/backend/abi/d2core.h ]; then
      install -Dm644 d2-core/backend/abi/d2core.h $out/include/d2core.h
    fi
  '';

  doCheck = false;

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2 core backend cdylib (d2core.h C ABI for Flutter dart:ffi)";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
