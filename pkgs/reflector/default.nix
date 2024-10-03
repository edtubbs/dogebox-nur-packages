{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "reflector";
  version = "0.0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/reflector.git";
    rev = "bbb24e1b4bdc68a0cbc955ea028c73daebfe9e1f";
  };

  vendorHash = "sha256-Dfdzc2wZWis2/Lla6VLYkSUNKw4dTw8kEGCGdDN0org=";

  nativeBuildInputs = [
    pkgs.go_1_21
  ];

  meta = with lib; {
    description = "Dogebox Reflector service";
    homepage = "https://github.com/dogeorg/reflector";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
