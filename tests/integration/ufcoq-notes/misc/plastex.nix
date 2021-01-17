### Nix expression for the plastex dependency of the project

let
  distributions = import ./distributions.nix;
  nixpkgsPath = distributions.nixpkgsPath;
  nixpkgs = import nixpkgsPath {};
  plastexFunction = ../../../../misc/install.nix;
  python = nixpkgs.python38;
  nixPythonPath = distributions.nixPythonPath;
  nixPython = import nixPythonPath { inherit nixpkgs python; };
  texlive = nixpkgs.texlive;
  dvipng = texlive.combine {
    inherit (texlive) scheme-infraonly dvipng;
  };
  plastex = nixpkgs.callPackage plastexFunction {
    inherit (nixpkgs) stdenv;
    inherit (python.pkgs) buildPythonPackage certifi chardet docopt
      jinja2 unidecode;
    inherit (nixPython) jinja2-ansible-filters;
    inherit (nixpkgs.lib) cleanSource;
    inherit dvipng;
  };
  pythonEnvironment =  python.withPackages (
    packages: with packages; [ pip setuptools ] ++ [ plastex ]
  );
in {
  packages = [ pythonEnvironment ];
}

### End of file
