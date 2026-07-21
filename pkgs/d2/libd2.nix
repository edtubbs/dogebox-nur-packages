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

  # To generate: leave as lib.fakeHash, build once, and replace with the
  # hash Nix reports.
  cargoHash = lib.fakeHash;

  # The workspace pins a toolchain in rust-toolchain.toml; the nixpkgs
  # rustPlatform toolchain is used instead. If the build requires the
  # pinned toolchain, switch to fenix or rust-overlay.

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
