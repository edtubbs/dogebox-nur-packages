{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "dogemap";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogemap.git";
    rev = "24f207c15ac655387c3040c791b559843b3b6814";
  };

  vendorHash = "sha256-7hRezOBcjB2wsx/SwV519wg3Azh+0kHMcAoc9aYPM3A=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Map service for Dogebox";
    homepage = "https://github.com/dogeorg/dogemap";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
