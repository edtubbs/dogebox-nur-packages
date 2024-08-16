{ lib, pkgs, stdenv, fetchurl, buildGoModule, ... }:

buildGoModule {
  pname = "dogeboxd";
  version = "0.1";

  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
  };

  vendorHash = "sha256-Nmw495UjpwrNDkJGXSQcf29O6HLelDlK4fNG8vgkKok=";

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
