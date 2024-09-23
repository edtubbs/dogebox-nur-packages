{ pkgs, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "radicle";
  version = "1.0.0";

  src = fetchurl {
    url = "https://files.radicle.xyz/releases/latest/${pname}-${version}-x86_64-unknown-linux-musl.tar.xz";
    hash = "sha256-btJnbw7/xyBrAe3imfhXrEfOx8HJvEQpuCb8ajWLTig=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a * $out
  '';

  meta = {
    description = "An open source, peer-to-peer code collaboration stack built on Git.";
    homepage = "https://radicle.xyz";
    changelog = "https://radicle.xyz/#updates";
  };
}
