### Makefile rules for a subproject

### ==================================================================
### all target
### ==================================================================

.PHONY: all

all: html pdf

### ==================================================================
### Rule for the bibliography-rnc-schema target
### ==================================================================

.PHONY: bibliography-rnc-schema

bibliography-rnc-schema: \
	${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNC_SCHEMA}

${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNC_SCHEMA}:
	${GENERATE_BIBLIOGRAPHY_RNC_SCHEMA}

### ==================================================================
### html target
### ==================================================================

.PHONY: html

html: ${MAIN_HTML_FILE}

${MAIN_HTML_FILE}: ${TEXMF_SOURCE_FILES}
	${PLASTEX}

### ==================================================================
### Rules for the pdf and the <papersize>-<mediatype> targets
### ==================================================================

.PHONY: pdf

## $1 = paper size (a4 / ipad), $2 = media type (print / screen),
define papersize_mediatype_TEMPLATE =
.PHONY pdf: $1-$2

.PHONY: ${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}/${MAIN_LATEX_FILE_STEM}.pdf

$1-$2: ${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}/${MAIN_LATEX_FILE_STEM}.pdf

${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}/${MAIN_LATEX_FILE_STEM}.pdf:
	mkdir -p ${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}
	$(call LATEXMK,$1,$2)
endef

$(foreach papersize,${PAPER_SIZES},$(foreach \
	mediatype,${MEDIA_TYPES},$(eval $(call \
	papersize_mediatype_TEMPLATE,${papersize},${mediatype}))))

### ==================================================================
### Rule for the tidy target
### ==================================================================

.PHONY: tidy

tidy: html ${TIDY_COOKIE}

${TIDY_COOKIE}: ${MAIN_HTML_FILE}
	${TIDY}

### ==================================================================
### Rule for the validate-html target
### ==================================================================

.PHONY: validate-html

validate-html: html
	${VALIDATE_HTML}

### ==================================================================
### Rule for the xml-bibliography target
### ==================================================================

.PHONY: xml-bibliography

xml-bibliography: ${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}

${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}: ${TEXMF_SOURCE_FILES}
	${GENERATE_XML_BIBLIOGRAPHY}

### ==================================================================
### Rule for the bibclean target
### ==================================================================

.PHONY: bibclean

bibclean:
	${BIBCLEAN}

### ==================================================================
### Rule for the clean target
### ==================================================================

.PHONY: clean

clean:
	${CLEAN}

### ==================================================================
### Verbosity target
### ==================================================================

${VERBOSE}.SILENT:

### End of file
