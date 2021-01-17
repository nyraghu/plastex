### Makefile for integration tests

### ==================================================================
### Variables
### ==================================================================

SHELL = /bin/sh
ACTUAL_OUTPUT_DIRECTORY = build
EXPECTED_OUTPUT_DIRECTORY = expected-output

define FILES =
html/type-theory/index.html \
html/type-theory/js/mathjax-configuration.js \
html/type-theory/sec-boolean-type.html \
html/type-theory/sec-comp-funct.html \
html/type-theory/sec-coproduct-two-types.html \
html/type-theory/sec-empty-type.html \
html/type-theory/sec-famil-as-funct.html \
html/type-theory/sec-function-types.html \
html/type-theory/sec-introduction.html \
html/type-theory/sec-natural-numbers.html \
html/type-theory/sec-paths.html \
html/type-theory/sec-pi-types.html \
html/type-theory/sec-product-two-types.html \
html/type-theory/sec-sigma-types.html \
html/type-theory/sec-some-basic-functions.html \
html/type-theory/sec-unit-type.html \
html/type-theory/sec-universes.html \
html/type-theory/styles/theme-blue.css \
html/type-theory/styles/theme-default.css \
html/type-theory/styles/theme-green.css \
pdf/a4-print/type-theory/main.pdf \
pdf/a4-screen/type-theory/main.pdf \
pdf/ipad-print/type-theory/main.pdf \
pdf/ipad-screen/type-theory/main.pdf
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

test: html@type-theory pdf@type-theory
	${COMMAND}

### End of file

