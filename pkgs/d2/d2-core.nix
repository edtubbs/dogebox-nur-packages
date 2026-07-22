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
  pname = "d2-core";
  inherit (source) version src;

  # The d2-core backend Go module builds a c-shared library
  # (see the repository Makefile).
  modRoot = "d2-core/backend";

  # To generate: leave as lib.fakeHash, build once, and replace with the
  # hash Nix reports.
  vendorHash = "sha256-B9aPABCU31WiEWxdsb6MT8cLxnkpxT1EnDZcjx9PW48=";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    libd2
  ];

  # The backend's cgo links against the libd2 Rust library via
  # -L../../../../libd2/target/release -ld2 (relative to
  # d2-core/backend/internal/ffi_libd2). Stage the prebuilt libd2
  # output where the link flags expect it.
  preBuild = ''
    mkdir -p ../../libd2/target/release
    cp ${libd2}/lib/* ../../libd2/target/release/
  '';

  buildPhase = ''
    runHook preBuild
    go build -buildmode=c-shared -o libd2core.so ./cmd/d2core-backend
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 libd2core.so $out/lib/libd2core.so
    if [ -f libd2core.h ]; then
      install -Dm644 libd2core.h $out/include/libd2core.h
    fi
    runHook postInstall
  '';

  # Private source: cannot be fetched or cached by public CI.
  preferLocalBuild = true;

  meta = with lib; {
    description = "D2 core backend c-shared library";
    homepage = "https://github.com/dogecoinfoundation/d2";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
