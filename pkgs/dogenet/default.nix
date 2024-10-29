{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dogenet";
  version = "0.4";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/dogenet.git";
    rev = "v0.1.7";
    hash = "sha256-9KoDouO0V6IKMx3oeBSpDRP977Y+frNEz+Eq0bumYwg=";
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
