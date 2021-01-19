### Makefile for integration tests

### ==================================================================
### Variables
### ==================================================================

TEST_ROOT = tests/integration
TEST_PROJECTS = bibliography ufcoq-notes
DIRECTORIES = $(addprefix ${TEST_ROOT}/,${TEST_PROJECTS})

## https://github.com/direnv/direnv/issues/68#issuecomment-162639262
define COMMAND =
export DIRENV_LOG_FORMAT=""; \
for directory in ${DIRECTORIES}; do \
	direnv allow $${directory}; \
	direnv exec $${directory} \
		${MAKE} -C $${directory} --no-print-directory test; \
done
endef

### ==================================================================
### Targets
### ==================================================================

.PHONY: integration-tests

integration-tests:
	@${COMMAND}

### End of file
