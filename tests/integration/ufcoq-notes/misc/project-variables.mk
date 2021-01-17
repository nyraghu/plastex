## Makefile variables for the project

### ==================================================================
### Project root
### ==================================================================

export PROJECT_ROOT = ${CURDIR}

### ==================================================================
### Project targets
### ==================================================================

## Targets that apply only to the project as a whole.
PROJECT_TARGETS = distclean nix-build nixclean

## Subproject targets are targets that apply to every subproject.
## Here are the subproject targets that need the Nix environment.
NIX_SUBPROJECT_TARGETS = all bibliography-rnc-schema html pdf tidy
NIX_SUBPROJECT_TARGETS += validate-html xml-bibliography

## $1 = paper size (a4 / ipad), $2 = media type (print / screen),
define PAPERSIZE_MEDIATYPE_TARGETS =
$(foreach papersize,${PAPER_SIZES},$(foreach \
	mediatype,${MEDIA_TYPES},${papersize}-${mediatype}))
endef

NIX_SUBPROJECT_TARGETS += ${PAPERSIZE_MEDIATYPE_TARGETS}

## Subproject targets that only clean something.
CLEAN_SUBPROJECT_TARGETS = bibclean clean

## All subproject targets.
define SUBPROJECT_TARGETS =
${NIX_SUBPROJECT_TARGETS} \
${CLEAN_SUBPROJECT_TARGETS}
endef

## The default target.
.DEFAULT_GOAL = all

### ==================================================================
### Subproject Makefile
### ==================================================================

export SUBPROJECT_MAKEFILE = ${PROJECT_ROOT}/misc/subproject.mk

### ==================================================================
### Variables related to Nix
### ==================================================================

NIX_BUILD_COOKIE = .nix_build_DONE

### ==================================================================
### Output directories
### ==================================================================

export BUILD_DIRECTORY = ${PROJECT_ROOT}/build
export HTML_DIRECTORY = ${BUILD_DIRECTORY}/html
export PDF_DIRECTORY = ${BUILD_DIRECTORY}/pdf

### ==================================================================
### Environment settings for Perl programs
### ==================================================================

## Avoid locale warnings when running Perl programs like biber and
## latexmk <https://github.com/NixOS/nix/issues/599>.
define PERL_ENVIRONMENT =
LOCALE_ARCHIVE=${PROJECT_ROOT}/result/lib/locale/locale-archive
endef

export PERL_ENVIRONMENT

### ==================================================================
### Reproducible PDF output
### ==================================================================

## https://tex.stackexchange.com/a/391541
define REPRODUCIBLE_PDF_OUTPUT_ENVIRONMENT =
SOURCE_DATE_EPOCH=0 \
FORCE_SOURCE_DATE=1
endef

export REPRODUCIBLE_PDF_OUTPUT_ENVIRONMENT

### ==================================================================
### Fonts for XeLaTeX
### ==================================================================

FONTS_DIRECTORY = ${PROJECT_ROOT}/result/share/fonts
TRUETYPE_DIRECTORY = ${FONTS_DIRECTORY}/truetype
OPENTYPE_DIRECTORY = ${FONTS_DIRECTORY}/opentype

DEJA_VU_FONTS_DIRECTORY = ${TRUETYPE_DIRECTORY}/dejavu
TEXFONTS ::= ${DEJA_VU_FONTS_DIRECTORY}//

define TEX_GYRE_PAGELLA_FONTS_DIRECTORY =
${OPENTYPE_DIRECTORY}/tex-gyre-pagella
endef
TEXFONTS ::= ${TEXFONTS}:${TEX_GYRE_PAGELLA_FONTS_DIRECTORY}//

UBUNTU_FONTS_DIRECTORY = ${TRUETYPE_DIRECTORY}/ubuntu-font-family
TEXFONTS ::= ${TEXFONTS}:${UBUNTU_FONTS_DIRECTORY}//

XITS_FONTS_DIRECTORY = ${OPENTYPE_DIRECTORY}/xits
TEXFONTS ::= ${TEXFONTS}:${XITS_FONTS_DIRECTORY}//

define TEXFONTS_ENVIRONMENT =
TEXFONTS=${TEXFONTS}:
endef

export TEXFONTS_ENVIRONMENT

### ==================================================================
### Paper sizes for the PDF output
### ==================================================================

export PAPER_SIZES = a4 ipad

### ==================================================================
### Type sizes for the PDF output
### ==================================================================

export a4_TYPE_SIZE = 11pt
export ipad_TYPE_SIZE = 10pt

### ==================================================================
### Media types for the PDF output
### ==================================================================

export MEDIA_TYPES = print screen

### ==================================================================
### Common data of subprojects
### ==================================================================

SUBPROJECTS_FILE = misc/subprojects
SUBPROJECTS = $(shell cat "${SUBPROJECTS_FILE}")
SUBPROJECTS_ROOT = src/main

### ==================================================================
### The `make' command for a subproject
### ==================================================================

## $1 = target, $2 = subproject name
define MAKE_SUBPROJECT =
${MAKE} \
--directory=${SUBPROJECTS_ROOT}/$2 \
--makefile=${SUBPROJECT_MAKEFILE} \
--no-print-directory \
$1
endef

### End of file
