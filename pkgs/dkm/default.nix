{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dkm";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dkm.git";
    rev = "ddbb3eb4022e90384306a5264bb88e4709dc69e7";
  };

  vendorHash = "sha256-bJeDnkn3sGWE9qbrqZfFj7WPjZ3c3WX0I0dBL4O5wKQ=";

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
