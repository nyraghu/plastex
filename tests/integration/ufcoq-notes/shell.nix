### Specification for nix-shell

let
  environment = import ./misc/environment.nix;
in environment.mkShell {
  buildInputs = environment.packages;
}

### End of file
