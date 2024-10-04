{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "jampuppy";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/jampuppy.git";
    rev = "v0.1.3";
    hash = "sha256-e32MCwQHKiGfstw1PGD1vnyA7JsnSFLi3RBjJ0RPqCI=";
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
