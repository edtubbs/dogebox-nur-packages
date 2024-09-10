{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

let
  dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "e9ff357d188b05bb84592455ba18670bf97a09db";
  };
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "e966ecc71dc433aee25d256ae73714a0530173be";
  };

  vendorHash = "sha256-Py1kZ7gLg0naQ7UIpmS7WNVV2S/rz8aYBYmGeisSh8g";

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
