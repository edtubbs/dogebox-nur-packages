{ 
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  ...
}:

stdenv.mkDerivation rec {
  pname = "rk3588-firmware";
  version = "2024.09.14";

  src = fetchGit {
    url = "https://github.com/friendlyarm/sd-fuse_rk3588.git";
    rev = "48302f720a1971fcb66bc75edbe624f5e6f9df8c";
  };

  installPhase = ''
    mkdir -p $out/etc $out/system $out/lib/firmware

    cp -av prebuilt/firmware/files/etc/*              $out/etc
    cp -av prebuilt/firmware/files/system/*           $out/system
    cp -av prebuilt/firmware/files/usr/lib/firmware/* $out/lib/firmware

    cp -av prebuilt/firmware/files2/usr/lib/firmware/regulatory.db     $out/lib/firmware
    cp -av prebuilt/firmware/files2/usr/lib/firmware/regulatory.db.p7s $out/lib/firmware
  '';

  meta = {
    description = "rk3588 Device Firmware";
    homepage = "https://github.com/friendlyarm/sd-fuse_rk3588";
    changelog = "https://github.com/friendlyarm/sd-fuse_rk3588/commits/kernel-6.1.y/";
  };
}
