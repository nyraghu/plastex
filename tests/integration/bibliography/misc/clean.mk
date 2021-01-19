.PHONY: bibclean clean distclean nix-clean

bibclean:
	${BIBCLEAN}

clean:
	${RM} -r ${BUILD_DIRECTORY}

distclean: bibclean clean nix-clean

nix-clean:
	${RM} result ${NIX_BUILD_COOKIE}
