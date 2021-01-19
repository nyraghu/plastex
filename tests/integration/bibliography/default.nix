let
  environment = import ./misc/environment.nix;
in environment.buildEnv {
  name = "plastex-test-bibliography";
  paths = environment.packages;
}
