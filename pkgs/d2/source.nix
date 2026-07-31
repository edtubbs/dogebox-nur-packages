# Shared pinned source for the private dogecoinfoundation/d2 repository.
#
# The d2 repository is private. fetchgit is a fixed-output derivation,
# so it is allowed network access, but SSH credentials are not available
# inside the Nix build sandbox by default. To build these packages the
# machine performing the fetch needs read access to the repository:
#
#   - Multi-user Nix: install a read-only GitHub deploy key for
#     dogecoinfoundation/d2 in the Nix daemon's root user SSH config
#     (e.g. /root/.ssh/), since fetches run as the daemon.
#   - Single-user Nix: build with `--option sandbox relaxed`, which
#     lets the fetch use your SSH agent.
#
# To regenerate the source hash on a machine with access:
#   nix-prefetch-git git@github.com:dogecoinfoundation/d2.git <rev>
{ pkgs }:

rec {
  # Pinned commit on the copilot/start-testnet-for-d2 branch.
  rev = "940908e9e520a7fa4b4f143f2aab0914830f8bc7";
  version = "1-unstable-2026-07-31";

  src = pkgs.fetchgit {
    url = "git@github.com:dogecoinfoundation/d2.git";
    inherit rev;
    # To regenerate: nix-prefetch-git git@github.com:dogecoinfoundation/d2.git <rev>
    hash = "sha256-Up/1YXiJcEp88SMLr3C2ZtLKRk7GJ/dG/TdxbMInX1U=";
  };
}
