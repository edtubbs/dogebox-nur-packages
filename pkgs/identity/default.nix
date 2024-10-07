{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "identity";
  version = "0.1";

  src = pkgs.fetchgit {
    url = "https://github.com/dogeorg/identity.git";
    rev = "v0.1.5";
    hash = "sha256-ntVeoKbnO7Y9pRXKB9xdExM2CwA2l4SKCqG8+ZRrtc8=";
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
