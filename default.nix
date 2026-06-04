let
  pkgs = import <nixpkgs> { };
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.12";

  src = pkgs.fetchurl {
    url = "https://ftp.gnu.org/gnu/hello/hello-${finalAttrs.version}.tar.gz";
    sha256 = "1ayhp9v4m4rdhjmnl2bq3cibrbqqkgjbl3s7yk2nhlh8vj3ay16g";
  };

  doInstallCheck = false;
  doCheck = false;
})
