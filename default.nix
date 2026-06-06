{
  pkgs ? import <nixpkgs> { },
}:
pkgs.dockerTools.buildLayeredImage {
  name = "cli-toolbox-nix";
  tag = "latest1";

  contents = with pkgs; [
    htop
    bash
    busybox
  ];

  config = {
    Cmd = [ "sh" ];
  };
}
