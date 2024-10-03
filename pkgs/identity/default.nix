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
    rev = "f8cb1c74a495ae4a96c844e30a1c8fa46ee53e4c";
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
