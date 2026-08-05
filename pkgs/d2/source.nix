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
  rev = "7ce96b12b1b4f8c5bae77b99217f2a20cb8f2146";
  version = "1-unstable-2026-08-05";

  src = pkgs.fetchgit {
    url = "git@github.com:dogecoinfoundation/d2.git";
    inherit rev;
    # To regenerate: nix-prefetch-git git@github.com:dogecoinfoundation/d2.git <rev>
    hash = "sha256-ubscaU2HZB0BqLfn5pNNtc/k3GE1C9xqumzQKP3xX+U=";
  };

  # The three Cargo workspaces in the repository (Makefile targets).
  # Each has its own Cargo.lock, vendored beside this file.
  workspaces = {
    libd2 = "libd2";
    d2-node = "d2-node";
    d2-core-backend = "d2-core/backend";
  };

  # Shared cargoLock options. The libd2 workspace has a private git
  # dependency (houseofdoge/km2) fetched over SSH, which cannot be
  # vendored inside the build sandbox. allowBuiltinFetchGit makes Nix
  # fetch git deps at evaluation time via builtins.fetchGit, which runs
  # as the invoking user and can use their SSH agent/keys.
  mkCargoLock = lockFile: {
    inherit lockFile;
    allowBuiltinFetchGit = true;
  };
}
