{
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  fetchurl ? pkgs.fetchurl,
  ...
}:

stdenv.mkDerivation rec {
  pname = "nrpe";
  version = "4.1.0";

  src = fetchurl {
    url = "https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-${version}/nrpe-${version}.tar.gz";
    hash = "sha256-ofFKqKr5NbV2zFWrXXe3y5ySDXcCr/RMnRjEyEHvjsw=";
  };

  patches = [ ./nrpe.patch ];

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.openssl.dev
  ];

  buildFlags = [ "all" ];

  meta = {
    description = "Nagios Remote Plugin Executor";
    homepage = "https://www.nagios.org/";
    changelog = "https://github.com/NagiosEnterprises/nrpe/blob/nrpe-${version}/CHANGELOG.md";
  };
}
