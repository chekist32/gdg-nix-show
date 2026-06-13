let
  mkDocker = import ./docker.nix { };
in
mkDocker { tag = "latest1"; }
