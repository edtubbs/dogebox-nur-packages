{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  source = import ./source.nix { inherit pkgs; };
  libd2 = pkgs.callPackage ./libd2.nix {};
in
buildGoModule {
  pname = "d2";
  inherit (source) version src;

  # The repository is polyglot: a Rust workspace in libd2/ (see libd2.nix)
  # and Go modules in d2-node/ (the node daemon, built here) and
  # d2-core/backend/ (see d2-core.nix).
  modRoot = "d2-node";

  vendorHash = "sha256-FJvuamr+XwvwDd1Is8fmYBXFLWZJQo5RfUlEVtwRVYw=";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    libd2
  ];

  # d2-node's cgo links against the libd2 Rust library via
  # -L../libd2/target/release -ld2 (relative to d2-node/internal/ffi).
  # Stage the prebuilt libd2 output where the link flags expect it.
  preBuild = ''
    mkdir -p ../libd2/target/release
    cp ${libd2}/lib/* ../libd2/target/release/
  '';

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
