{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dkm";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dkm.git";
    rev = "e9d027abedf874353cbc9b1404b07961bee77792";
  };

  vendorHash = "sha256-IxjlMOYvEW3hRyvwlqyWBs2KjjXQE/IYpX+LF3DsWEM=";

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
