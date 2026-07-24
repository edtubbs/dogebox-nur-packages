{ pkgs }:

rec {
  # Pinned commit from the private houseofdoge/km2 repository.
  rev = "fa71ea1319246ac09edea115e056924ddeda6b94";
  version = "0-unstable-2026-06-25";

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
    hash = "sha256-uDs3qhfn4WKbaUdh5QzWepxulG4p3XHr1DjtFdOID0k=";
  };
}
