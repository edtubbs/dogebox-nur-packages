{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  buildGoModule ? pkgs.buildGoModule,
  ...
}:

let
  dpanel = fetchGit {
    url = "https://github.com/dogeorg/dpanel.git";
    rev = "f2e2189670c0c39ae5139305c475621c50d93625";
  };
in

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "6dd0a1745ced496e5172753431313e4134d776f6";
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
