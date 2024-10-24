{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dogenet";
  version = "0.3";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/dogenet.git";
    rev = "v0.1.6";
    hash = "sha256-etukNGznCO0DSNJ39wccGLBjvuVKYoY6Og5rMapGgoY=";
  };

  vendorHash = "sha256-4XDgSVH+QAlIAv5/h30oqeVzMTEoAfEAySkVmMH6kFs=";

  nativeBuildInputs = [
    pkgs.go
    pkgs.gzip
  ];

  meta = with lib; {
    description = "Maps the Dogecoin network";
    homepage = "https://github.com/dogeorg/dogenet";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
