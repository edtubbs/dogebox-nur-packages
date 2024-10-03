{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "e00d5cd875f8e2f8334d5d7b9830b430177095a7";
  };
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "d95e6388a5b08e7e0cf068ce6f30037438519c21";
  };

  vendorHash = "sha256-Z0maOpolSBoYYN/oomPHNZurMNjyMhS0QUMg3MgmvcU=";

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/dogeboxd/bin
    cp build/* $out/dogeboxd/bin/

    mkdir -p $out/dpanel
    cp -r ${dpanel}/. $out/dpanel/
  '';

  doCheck = false;

  nativeBuildInputs = [
    pkgs.go_1_22
  ];

  buildInputs = [
    pkgs.systemd.dev
  ];

  meta = with lib; {
    description = "Dogebox OS system manager service";
    homepage = "https://github.com/dogeorg/dogeboxd";
    license = licenses.mit;
    maintainers = with maintainers; [ dogecoinfoundation ];
    platforms = platforms.all;
  };
}
