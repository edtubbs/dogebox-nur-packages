{ pkgs }:

rec {
  # Pinned commit from the private houseofdoge/km2 repository.
  rev = "83b6d1ce1d8746186bce037770bce1069a5fb9dd";
  version = "0-unstable-2026-07-23";

  # This private source is fetched over SSH. On multi-user Nix, untrusted
  # users cannot relax sandboxing and `pkgs.fetchgit` runs in the daemon
  # sandbox where `ssh` may be unavailable. Use builtins.fetchGit so the
  # fetch runs at evaluation time in the invoking user's context.
  src = builtins.fetchGit {
    url = "git@github.com:houseofdoge/km2.git";
    inherit rev;
  };
}
