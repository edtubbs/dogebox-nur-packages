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
    rev = "d157aec662749c80e83ae2d240cf8c3b376cdc7f";
  };

  vendorHash = "sha256-Dfdzc2wZWis2/Lla6VLYkSUNKw4dTw8kEGCGdDN0org=";

  nativeBuildInputs = [
    pkgs.go_1_22
  ];

  meta = with lib; {
    description = "Dogebox Reflector service";
    homepage = "https://github.com/dogeorg/reflector";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
