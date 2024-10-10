{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "identity";
  version = "0.2";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/identity.git";
    rev = "v0.1.7";
    hash = "sha256-RmyIVeO6ggQ/B6EEvlTRuTs/6dhtiW4d34+96gChdcc=";
  };

  vendorHash = "sha256-QU7tXH3A/o4RprM2j9etPrIkqetYln/Dc4wbO3Hk0T4=";

  nativeBuildInputs = [
    pkgs.go
  ];

  meta = with lib; {
    description = "Dogecoin Identity Protocol Handler";
    homepage = "https://github.com/dogeorg/identity";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
