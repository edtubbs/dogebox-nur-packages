{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dogenet";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogenet.git";
    rev = "610b952f7389b80b894d00f5290c5e0861c429c4";
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
