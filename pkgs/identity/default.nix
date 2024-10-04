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
    rev = "v0.1.4";
    hash = "sha256-zgHoQo5oUBoNOHqCVeoTw/q5s7BeBhzD1e19kNu0vac=";
  };

  vendorHash = "sha256-NnxDs9ZcvFCqpW+XCLMQZg22PIod7MS2hpVpmzNKsrE=";

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
