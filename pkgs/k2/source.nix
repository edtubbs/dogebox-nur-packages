{ pkgs }:

rec {
  # Pinned commit from the private houseofdoge/km2 repository.
  rev = "83b6d1ce1d8746186bce037770bce1069a5fb9dd";
  version = "0-unstable-2026-07-23";

  src = pkgs.fetchgit {
    url = "git@github.com:houseofdoge/km2.git";
    inherit rev;
    # To regenerate: nix-prefetch-git git@github.com:houseofdoge/km2.git <rev>
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
}
