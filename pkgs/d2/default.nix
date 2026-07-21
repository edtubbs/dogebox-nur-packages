{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  # Pinned commit on the copilot/start-testnet-for-d2 branch.
  rev = "a8ca5114a03bb0e7343d27e19955b4ff889972b9";
in
buildGoModule {
  pname = "d2";
  version = "0-unstable-2026-07-21";

  # The d2 repository is private. fetchgit is a fixed-output derivation,
  # so it is allowed network access, but SSH credentials are not available
  # inside the Nix build sandbox by default. To build this package the
  # machine performing the fetch needs read access to the repository:
  #
  #   - Multi-user Nix: install a read-only GitHub deploy key for
  #     dogecoinfoundation/d2 in the Nix daemon's root user SSH config
  #     (e.g. /root/.ssh/), since fetches run as the daemon.
  #   - Single-user Nix: build with `--option sandbox relaxed`, which
  #     lets the fetch use your SSH agent.
  #
  # To generate the source hash on a machine with access:
  #   nix-prefetch-git git@github.com:dogecoinfoundation/d2.git a8ca5114a03bb0e7343d27e19955b4ff889972b9
  # Then replace `hash` below. Leave `vendorHash = lib.fakeHash`, build once,
  # and replace it with the hash Nix reports.
  src = pkgs.fetchgit {
    url = "git@github.com:dogecoinfoundation/d2.git";
    inherit rev;
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;

  nativeBuildInputs = [
    pkgs.go
  ];

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
