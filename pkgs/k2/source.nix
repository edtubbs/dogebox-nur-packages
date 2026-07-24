{ pkgs }:

rec {
  # Pinned commit from the private houseofdoge/km2 repository.
  rev = "83b6d1ce1d8746186bce037770bce1069a5fb9dd";
  version = "0-unstable-2026-07-23";

  # fetchgit is a fixed-output derivation, so it is allowed network access
  # inside the sandbox. The machine performing the fetch needs read access
  # to the private repository (e.g. a read-only deploy key in the Nix
  # daemon's root user SSH config on multi-user Nix).
  #
  # To regenerate the hash: build once with the placeholder below and copy
  # the "got" hash from the mismatch error, or run
  #   nix-prefetch-git git@github.com:houseofdoge/km2.git <rev>
  src = pkgs.fetchgit {
    url = "git@github.com:houseofdoge/km2.git";
    inherit rev;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
}
