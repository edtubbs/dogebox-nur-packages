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
  pname = "k2";
  inherit (source) version src;

  # To generate: leave as lib.fakeHash, build once, and replace with the
  # hash Nix reports.
  cargoHash = lib.fakeHash;

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "K2 private Rust package";
    homepage = "https://github.com/houseofdoge/km2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
