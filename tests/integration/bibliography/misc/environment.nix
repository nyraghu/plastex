let
  plastex = import ./plastex.nix;
  texmf = import ./texmf.nix;
  general = import ./general.nix;
  packages = plastex.packages ++ texmf.packages ++ general.packages;
in {
  inherit (general) buildEnv mkShell;
  inherit packages;
}
