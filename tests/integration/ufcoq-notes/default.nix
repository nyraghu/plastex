## Specification for nix-build

let
  environment = import ./misc/environment.nix;
in environment.buildEnv {
  name = "plastex-test-ufcoq-notes";
  paths = environment.packages;
}

### End of file
