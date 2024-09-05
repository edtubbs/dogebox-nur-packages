{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dogenet";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogenet.git";
  };

  vendorHash = "sha256-5R+5XQZG6Qjk5m2/Oxq4c4qKbxDcnYz57jdNr8ImcqI=";

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
