{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  source = import ./source.nix { inherit pkgs; };
in
buildGoModule {
  pname = "d2";
  inherit (source) version src;

  # The repository is polyglot: a Rust workspace in libd2/ (see libd2.nix)
  # and Go modules in d2-node/ (the node daemon, built here) and
  # d2-core/backend/ (see d2-core.nix).
  modRoot = "d2-node";

  vendorHash = "sha256-FJvuamr+XwvwDd1Is8fmYBXFLWZJQo5RfUlEVtwRVYw=";

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2 node daemon";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
