{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dkm";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dkm.git";
    rev = "d915351ba924766c0985edf5d318d3ecb0914844";
  };

  vendorHash = "sha256-9smxGxt+XHXc6KZnGxCQ9SlFGPu7BmsLATV/O4fybFU=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Doge Key Manager";
    homepage = "https://github.com/dogeorg/dkm";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
