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
  pname = "d2-node";
  inherit (source) version src;

  # d2 migrated from Go to Rust: d2-node is now a Cargo workspace
  # (d2-node/Cargo.toml, members crates/d2-node and crates/d2-rpc-types).
  # The whole tree must stay unpacked because d2-node/crates/d2-node
  # depends on ../../../libd2/crates/d2 by path.
  cargoRoot = "d2-node";
  buildAndTestSubdir = "d2-node";

  # ./Cargo.lock.d2-node must be kept in sync with d2-node/Cargo.lock
  # from the pinned d2 revision:
  #   cp <d2-checkout>/d2-node/Cargo.lock pkgs/d2/Cargo.lock.d2-node
  cargoLock = source.mkCargoLock ./Cargo.lock.d2-node;

  # Only the daemon binary; the workspace also contains d2-rpc-types
  # which is a library consumed by d2-core/backend.
  cargoBuildFlags = [ "-p" "d2-node" ];
  cargoTestFlags = [ "-p" "d2-node" ];

  nativeBuildInputs = [
    pkgs.pkg-config
    # blst and secp256k1 build C code via cc.
    pkgs.perl
  ];

  buildInputs = [
    pkgs.openssl
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # The workspace pins a toolchain in rust-toolchain.toml; the nixpkgs
  # rustPlatform toolchain is used instead. If the build requires the
  # pinned toolchain, switch to fenix or rust-overlay.

  # Tests are run in d2's own CI (make test) and some libd2 unit tests
  # fail on this pinned revision.
  doCheck = false;

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2 node daemon (Rust)";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    mainProgram = "d2-node";
    platforms = platforms.all;
  };
}
