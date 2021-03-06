.PHONY: all html rnc-schema tidy validate-html xml-bibliography

all: html

html: nix-build ${MAIN_HTML_FILE}

${MAIN_HTML_FILE}: ${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}
	${PLASTEX}

${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}: ${TEXMF_SOURCE_FILES}
	${MAKE} ipad-screen
	${GENERATE_XML_BIBLIOGRAPHY}

tidy: html ${TIDY_COOKIE}

${TIDY_COOKIE}: ${MAIN_HTML_FILE}
	${TIDY}

validate-html: html
	${VALIDATE_HTML}

xml-bibliography: ${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}

rnc-schema: ${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNC_SCHEMA}

${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNC_SCHEMA}: \
		${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}
	${GENERATE_BIBLIOGRAPHY_RNC_SCHEMA}
