### Makefile for integration tests

### ==================================================================
### Variables
### ==================================================================

TEST_ROOT = tests/integration
TEST_PROJECTS = ufcoq-notes
DIRECTORIES = $(addprefix ${TEST_ROOT}/,${TEST_PROJECTS})

## https://github.com/direnv/direnv/issues/68#issuecomment-162639262
define COMMAND =
for directory in ${DIRECTORIES}; do \
	export DIRENV_LOG_FORMAT=""; \
	cd $${directory}; \
	direnv allow .; \
	direnv exec . ${MAKE} --no-print-directory test; \
done
endef

### ==================================================================
### Targets
### ==================================================================

.PHONY: integration-tests

integration-tests:
	@${COMMAND}

### End of file
