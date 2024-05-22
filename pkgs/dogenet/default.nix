{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dogenet";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogenet.git";
  };

  vendorHash = null;

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Maps the Dogecoin network";
    homepage = "https://github.com/dogeorg/dogenet";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
