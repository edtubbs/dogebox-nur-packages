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
  pname = "d2-core";
  inherit (source) version src;

  # The d2-core backend Go module builds a c-shared library
  # (see the repository Makefile).
  modRoot = "d2-core/backend";

  # To generate: leave as lib.fakeHash, build once, and replace with the
  # hash Nix reports.
  vendorHash = lib.fakeHash;

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
