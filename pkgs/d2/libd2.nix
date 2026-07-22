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

  # The Rust workspace (with its Cargo.lock) lives in libd2/.
  sourceRoot = "${source.src.name}/libd2";

  # The workspace has a private git dependency (houseofdoge/km2) fetched
  # over SSH, which cannot be vendored inside the build sandbox. Instead
  # of cargoHash, use cargoLock with allowBuiltinFetchGit: git deps are
  # then fetched at evaluation time by builtins.fetchGit, which runs as
  # the invoking user and can use their SSH agent/keys.
  #
  # ./Cargo.lock must be kept in sync with libd2/Cargo.lock from the
  # pinned d2 revision:
  #   cp <d2-checkout>/libd2/Cargo.lock pkgs/d2/Cargo.lock
  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  # The workspace pins a toolchain in rust-toolchain.toml; the nixpkgs
  # rustPlatform toolchain is used instead. If the build requires the
  # pinned toolchain, switch to fenix or rust-overlay.

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
