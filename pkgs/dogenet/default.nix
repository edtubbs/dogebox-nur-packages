{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  geodb = pkgs.fetchurl {
    url = "https://github.com/sapics/ip-location-db/raw/main/dbip-city/dbip-city-ipv4-num.csv.gz";
    sha256 = "sha256-Co5NJ1+puxFAubWf289JLolcWxYYkAAb54evAo1mJxs=";
  };
in
buildGoModule {
  pname = "dogenet";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/dogenet.git";
    rev = "v0.1.0";
    hash = "sha256-SQb3aYU6QakkrPpgYRT8KeyITI+Ld99WvL0oo+KGcHg=";
  };

  vendorHash = "sha256-5wV+yH0+ublvXhMpLkru8Y9WCMLy/FK1SG6qozH1CMg=";

  nativeBuildInputs = [
    pkgs.go
    pkgs.gzip
  ];

  postInstall = ''
    mkdir -p $out/bin/storage
    cp ${geodb} ./dbip-city-ipv4-num.csv.gz
    gzip -d dbip-city-ipv4-num.csv.gz
    mv dbip-city-ipv4-num.csv $out/bin/storage/dbip-city-ipv4-num.csv
  '';

  meta = with lib; {
    description = "Maps the Dogecoin network";
    homepage = "https://github.com/dogeorg/dogenet";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
