{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/8c50a710ddca43d7a530fb805ad55bde8d0141c5.tar.gz";
    sha256 = "0am8xx09fx5yf2p0wb001v0jx1g5hrfb76h4r37xph378jgk7pcr";
  }) { },
}:
{ tag }:
let
  terminfo =
    pkgs.runCommand "terminfo"
      {
        __structuredAttrs = true;
        unsafeDiscardReferences = {
          out = true;
        };
        nativeBuildInputs = [ pkgs.nukeReferences ];
      }
      ''
        mkdir -p $out/usr/share/terminfo
        cp -r ${pkgs.pkgsStatic.ncurses}/share/terminfo/. $out/usr/share/terminfo/
        nuke-refs $out/usr/share/terminfo/
      '';
  htopBin =
    pkgs.runCommand "htop-bin"
      {
        nativeBuildInputs = [ pkgs.nukeReferences ];
      }
      ''
        mkdir -p $out/bin
        cp ${pkgs.pkgsStatic.htop}/bin/htop $out/bin/htop
        nuke-refs $out/bin/htop
      '';
in
pkgs.dockerTools.buildLayeredImage {
  name = "cli-toolbox-nix";
  inherit tag;

  contents = with pkgs.pkgsStatic; [
    terminfo
    htopBin
    busybox
  ];

  config = {
    Cmd = [ "sh" ];
  };
}
