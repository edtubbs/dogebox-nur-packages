{ pkgs, stdenv, lib, ... }:

stdenv.mkDerivation {
  pname = "dogeboxd";
  version = "0.1";
  src = fetchGit {
    url = "https://github.com/dogeorg/dogeboxd.git";
  };
  nativeBuildInputs = [];
  buildInputs = [];
  meta = with lib; {
    broken = true;
    description = "Dogebox OS system manager service";
    homepage = "https://github.com/dogeorg/dogeboxd";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
