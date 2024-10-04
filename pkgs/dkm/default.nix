{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dkm";
  version = "0.1.1";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/dkm.git";
    rev = "v0.1.1";
    hash = "sha256-mSgdf9Msj834smUjpDNoZHRVg8Q5vBee0jFzRhNFmto=";
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
