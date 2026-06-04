{
  pkgs ?
    import
      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8c50a710ddca43d7a530fb805ad55bde8d0141c5.tar.gz")
      { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
        jupyter
        numpy
        matplotlib
      ]
    ))
  ];

  shellHook = ''
    echo "🐍 Python: $(python --version)"
    echo "📓 Jupyter: $(jupyter --version | head -1)"

    jupyter notebook demo.ipynb
  '';
}
