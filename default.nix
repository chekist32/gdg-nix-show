{
  pkgs ? import <nixpkgs> { },
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
    echo ""
    echo "run: jupyter notebook demo.ipynb"
  '';
}
