{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
    rev = "674dc27aef30cbef33fa2934bf5faaf44a99bc2b";
  };

  vendorHash = "sha256-Py1kZ7gLg0naQ7UIpmS7WNVV2S/rz8aYBYmGeisSh8g=";

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/dogeboxd $out/bin
  '';

  nativeBuildInputs = [
    pkgs.go
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
