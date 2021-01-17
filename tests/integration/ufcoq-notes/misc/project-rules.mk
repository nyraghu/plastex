## Makefile rules for the project

### ==================================================================
### Project targets
### ==================================================================

## distclean target

.PHONY: distclean

distclean: bibclean clean nixclean

## nix-build target

.PHONY: nix-build

nix-build: ${NIX_BUILD_COOKIE}

${NIX_BUILD_COOKIE}: default.nix misc/*.nix
	nix-build
	touch $@

## nixclean target

nixclean:
	${RM} result ${NIX_BUILD_COOKIE}

### ==================================================================
### Subproject targets
### ==================================================================

## $1 = target, $2 = subproject name
define subproject_target_TEMPLATE =
.PHONY: $1 $1@$2
$1: $1@$2

$1@$2:
	$(call MAKE_SUBPROJECT,$1,$2)
endef

$(foreach target,${SUBPROJECT_TARGETS},$(foreach \
	subproject,${SUBPROJECTS},$(eval $(call \
	subproject_target_TEMPLATE,${target},${subproject}))))

### ==================================================================
### Subproject targets that need the Nix environment
### ==================================================================

## $1 = target, $2 = subproject name
define nix_subproject_target_TEMPLATE =
$1@$2: nix-build
endef

$(foreach target,${NIX_SUBPROJECT_TARGETS},$(foreach \
	subproject,${SUBPROJECTS},$(eval $(call \
	nix_subproject_target_TEMPLATE,${target},${subproject}))))

### ==================================================================
### Verbosity target
### ==================================================================

${VERBOSE}.SILENT:

### End of file
