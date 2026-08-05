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
  pname = "libd2";
  inherit (source) version src;

  # The Rust workspace (with its own Cargo.lock) lives in libd2/.
  # It is self-contained: no path deps outside libd2/.
  cargoRoot = "libd2";
  buildAndTestSubdir = "libd2";

  # ./Cargo.lock.libd2 must be kept in sync with libd2/Cargo.lock from
  # the pinned d2 revision:
  #   cp <d2-checkout>/libd2/Cargo.lock pkgs/d2/Cargo.lock.libd2
  #
  # The workspace has a private git dependency (houseofdoge/km2) fetched
  # over SSH, which cannot be vendored inside the build sandbox; see
  # mkCargoLock in source.nix.
  cargoLock = source.mkCargoLock ./Cargo.lock.libd2;

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.perl
  ];

  # d2-node and d2-core/backend no longer link against a prebuilt
  # libd2: since the Go-to-Rust migration they depend on the libd2
  # crates by Cargo path and compile them in-tree. This derivation is
  # standalone (rlibs + the d2 facade), matching `make build`'s first
  # step.
  postInstall = ''
    mkdir -p $out/lib
    find target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release \
      -maxdepth 1 \( -name 'libd2.rlib' -o -name 'libd2.so' -o -name 'libd2.a' -o -name 'libd2.dylib' \) \
      -exec install -Dm644 {} $out/lib/ \;
  '';

  # The d2-crypto poseidon unit tests fail on this pinned revision
  # (constant/vector mismatches upstream); tests are run in d2's own CI,
  # so skip them here.
  doCheck = false;

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2 core Rust libraries (libd2 workspace)";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
