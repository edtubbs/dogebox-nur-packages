{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

let
  dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "11952f9b1acd28deef72ce8fd6459f1b2014c41a";
  };
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "8ddaafb26a852d2bbd5f3e1a74635d72e61feee7";
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
