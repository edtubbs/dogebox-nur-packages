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

  # Use the lockfile from the pinned source revision so crates are fetched
  # from lockfile metadata instead of the crates.io API vendor staging flow.
  cargoLock = {
    lockFile = "${source.src}/Cargo.lock";
  };

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
