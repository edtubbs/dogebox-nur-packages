{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "jampuppy";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/jampuppy.git";
  };

  vendorHash = "sha256-3PnXB8AfZtgmYEPJuh0fwvG38dtngoS/lxyx3H+rvFs=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "A Jam Stack tool for Dogebox";
    homepage = "https://github.com/dogeorg/jampuppy";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
