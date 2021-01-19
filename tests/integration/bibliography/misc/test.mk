### Makefile for integration tests

### ==================================================================
### Variables
### ==================================================================

SHELL = /bin/sh
ACTUAL_OUTPUT_DIRECTORY = build
EXPECTED_OUTPUT_DIRECTORY = expected-output

define FILES =
html/bibliography.html \
html/index.html \
html/sec-hello-universe.html \
html/sec-hello-world.html \
html/js/mathjax-configuration.js \
pdf/a4-print/main.pdf \
pdf/a4-screen/main.pdf \
pdf/ipad-print/main.pdf \
pdf/ipad-screen/main.pdf \
html/styles/theme-blue.css \
html/styles/theme-default.css \
html/styles/theme-green.css
endef

ACTUAL_FILES = $(addprefix ${ACTUAL_OUTPUT_DIRECTORY}/./,${FILES})

define COMMAND =
${SHELL} misc/md5cmp.sh \
${ACTUAL_OUTPUT_DIRECTORY} \
${EXPECTED_OUTPUT_DIRECTORY} \
${FILES}
endef

### ==================================================================
### Targets
### ==================================================================

.PHONY: generate-expected-output test

generate-expected-output:
	mkdir -p ${EXPECTED_OUTPUT_DIRECTORY}
	rsync --relative ${ACTUAL_FILES} ${EXPECTED_OUTPUT_DIRECTORY}

test: html pdf
	@${COMMAND}

### End of file
