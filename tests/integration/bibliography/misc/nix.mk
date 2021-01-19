.PHONY: nix-build

nix-build: ${NIX_BUILD_COOKIE}

${NIX_BUILD_COOKIE}: default.nix misc/*.nix
	nix-build
	touch $@
