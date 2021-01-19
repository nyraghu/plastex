let
  distributions = import ./distributions.nix;
  nixpkgsPath = distributions.nixpkgsPath;
  nixpkgs = import distributions.nixpkgsPath {};
  nixJvmPath = distributions.nixJvmPath;
  nixJvm = import nixJvmPath { inherit nixpkgs; };
  nixpkgsPackages = with nixpkgs; [
    biber glibcLocales html-tidy jing-trang
  ];
  nixJvmPackages = [ nixJvm.nu-html-checker ] ;
  packages = nixpkgsPackages ++ nixJvmPackages;
in {
  inherit (nixpkgs) buildEnv mkShell;
  inherit packages;
}
