{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

buildGoModule {
  pname = "identity";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/identity.git";
    rev = "6305bca3fd4b2c150c4795cafc7bd9ced8812d1d";
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
