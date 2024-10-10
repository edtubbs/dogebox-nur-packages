{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  geodb = pkgs.fetchurl {
    url = "https://github.com/sapics/ip-location-db/raw/0359bf3c26c75cd38da56aa28f28895098f01dbb/dbip-city/dbip-city-ipv4-num.csv.gz";
    sha256 = "sha256-Co5NJ1+puxFAubWf289JLolcWxYYkAAb54evAo1mJxs=";
  };
in
buildGoModule {
  pname = "dogemap-backend";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/dogemap-backend.git";
    rev = "v0.1.0";
    hash = "sha256-R9JpEFL2fPfR0A2Ma37MGSbuBrI08pSN4I2szNZO9R4=";
  };

  vendorHash = "sha256-98LKOqj84iW/XfHq8ULlLG70WQsBjCR89gnwtW8Lh18=";

  nativeBuildInputs = [
    pkgs.go
  ];

  postInstall = ''
    mkdir -p $out/storage
    cp ${geodb} ./dbip-city-ipv4-num.csv.gz
    gzip -d dbip-city-ipv4-num.csv.gz
    mv dbip-city-ipv4-num.csv $out/storage/dbip-city-ipv4-num.csv
  '';

  meta = with lib; {
    description = "Map service for Dogebox";
    homepage = "https://github.com/dogeorg/dogemap";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
