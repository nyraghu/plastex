let
  distributions = import ./distributions.nix;
  nixpkgsPath = distributions.nixpkgsPath;
  nixpkgs = import nixpkgsPath {};
  nixMiscellanyPath = distributions.nixMiscellanyPath;
  nixMiscellany = import nixMiscellanyPath { inherit nixpkgs; };
  texmfPath = distributions.texmfPath;
  texmf = import texmfPath {
    inherit (nixpkgs) callPackage stdenv texlive gawk glibcLocales;
    inherit (nixpkgs.lib) cleanSource;
    inherit (nixMiscellany) dejavu-fonts ubuntu-font-family
      tex-gyre-pagella xits;
    inherit (nixpkgs.python38Packages) pygments;
  };
in {
  inherit (texmf) packages;
}
