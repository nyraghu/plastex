### Makefile variables for a subproject

### ==================================================================
### Subproject name
### ==================================================================

SUBPROJECT_DIRECTORY = ${CURDIR}
SUBPROJECT = $(notdir ${SUBPROJECT_DIRECTORY})

### ==================================================================
### The default target for the subproject
### ==================================================================

.DEFAULT_GOAL = all

### ==================================================================
### LaTeX files of the subproject
### ==================================================================

MAIN_LATEX_FILE = main.tex
MAIN_LATEX_FILE_STEM = $(notdir $(basename ${MAIN_LATEX_FILE}))
LATEX_FILES = $(shell find * -name '*.tex')

### ==================================================================
### Bibliography files of the subproject
### ==================================================================

BIBLIOGRAPHY_DIRECTORY = ${SUBPROJECT_DIRECTORY}/bibliography
BIBLATEX_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}.bib
XML_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}.bltxml
BIBLIOGRAPHY_RNG_SCHEMA = ${MAIN_LATEX_FILE_STEM}.rng
BIBLIOGRAPHY_RNC_SCHEMA = ${MAIN_LATEX_FILE_STEM}.rnc
BIBER_CONTROL_FILE = ${MAIN_LATEX_FILE_STEM}.bcf
USED_ENTRIES_BIBLATEX_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}_used.bib

define BIBLATEX_ENVIRONMENT =
BLTXMLINPUTS=${BIBLIOGRAPHY_DIRECTORY}//: \
BIBINPUTS=${BIBLIOGRAPHY_DIRECTORY}//:
endef

### ==================================================================
### Environment settings for commands
### ==================================================================

define ENVIRONMENT =
${PERL_ENVIRONMENT} \
${REPRODUCIBLE_PDF_OUTPUT_ENVIRONMENT} \
${TEXFONTS_ENVIRONMENT} \
${BIBLATEX_ENVIRONMENT}
endef

### ==================================================================
### TeXMF source files of the subproject
### ==================================================================

define TEXMF_SOURCE_FILES =
${LATEX_FILES} \
$(realpath ${BIBLIOGRAPHY_DIRECTORY}/${BIBLATEX_BIBLIOGRAPHY})
endef

### ==================================================================
### The main HTML output file
### ==================================================================

MAIN_HTML_FILE = ${HTML_DIRECTORY}/${SUBPROJECT}/index.html

### ==================================================================
### The location of the MathJax script
### ==================================================================

## Relative to ${HTML_DIRECTORY}/${SUBPROJECT}.
MATHJAX_URL = "js/mathjax/tex-chtml.js"

### ==================================================================
### Command for producing the HTML output of the project
### ==================================================================

define PLASTEX =
if [ -e ${BIBLIOGRAPHY_DIRECTORY}/${BIBLATEX_BIBLIOGRAPHY} ] ; \
then \
${MAKE} --makefile=${SUBPROJECT_MAKEFILE} xml-bibliography ; \
else \
echo "Warning: the subproject ${SUBPROJECT} does not have a \
bibliography." ; \
fi

${ENVIRONMENT} plastex \
--dir=${HTML_DIRECTORY}/${SUBPROJECT} \
--renderer=HTMLNotes \
--html-notes-mathjax-url=${MATHJAX_URL} \
${MAIN_LATEX_FILE}
@${RM} ${MAIN_LATEX_FILE_STEM}.paux
@echo
endef

### ==================================================================
### Command for the RNC schema of the bibliography of the subproject
### ==================================================================

define GENERATE_BIBLIOGRAPHY_RNC_SCHEMA =
if [ -e ${BIBLIOGRAPHY_DIRECTORY}/${BIBLATEX_BIBLIOGRAPHY} ] ; \
then \
${MAKE} --makefile=${SUBPROJECT_MAKEFILE} xml-bibliography ; \
cd ${BIBLIOGRAPHY_DIRECTORY} ; \
trang ${BIBLIOGRAPHY_RNG_SCHEMA} ${BIBLIOGRAPHY_RNC_SCHEMA} ; \
else \
echo "Warning: the subproject ${SUBPROJECT} does not have a \
bibliography" ; \
fi
endef

### ==================================================================
### Command for tidying the HTML output of the subproject
### ==================================================================

TIDY_COOKIE = ${HTML_DIRECTORY}/${SUBPROJECT}/.tidy_DONE

define TIDY =
tidy \
--fix-uri no \
--quiet yes \
--tidy-mark no \
--wrap 0 \
--write-back yes \
${HTML_DIRECTORY}/${SUBPROJECT}/*.html

touch ${TIDY_COOKIE}
endef

### ==================================================================
### Command for validating the HTML output of the subproject
### ==================================================================

define VALIDATE_HTML =
nu-html-checker ${HTML_DIRECTORY}/${SUBPROJECT}/*.html
endef

### ==================================================================
### Command for generating the XML bibliography of the subproject
### ==================================================================

define GENERATE_XML_BIBLIOGRAPHY =
if [ -e ${BIBLIOGRAPHY_DIRECTORY}/${BIBLATEX_BIBLIOGRAPHY} ] ; \
then \
\
${MAKE} --makefile=${SUBPROJECT_MAKEFILE} ipad-screen ; \
\
mkdir -p ${HTML_DIRECTORY} ; \
\
${ENVIRONMENT} biber \
--input-directory=${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT} \
--output-directory=${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT} \
--input-encoding=UTF-8 \
--output-encoding=UTF-8 \
--output-file=${BIBLATEX_BIBLIOGRAPHY} \
--output-format=bibtex \
${BIBER_CONTROL_FILE} ; \
\
${ENVIRONMENT} biber \
--input-directory=${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT} \
--output-directory=${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT} \
--input-encoding=UTF-8 \
--output-encoding=UTF-8 \
--output-file=${XML_BIBLIOGRAPHY} \
--output-format=biblatexml \
--output-resolve-xdata \
--tool \
${BIBLATEX_BIBLIOGRAPHY} ; \
\
cp ${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT}/${BIBLATEX_BIBLIOGRAPHY} \
${BIBLIOGRAPHY_DIRECTORY}/${USED_ENTRIES_BIBLATEX_BIBLIOGRAPHY} ; \
\
cp ${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT}/${XML_BIBLIOGRAPHY} \
${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY} ; \
\
cp ${PDF_DIRECTORY}/ipad-screen/${SUBPROJECT}/${BIBLIOGRAPHY_RNG_SCHEMA} \
${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNG_SCHEMA} ; \
\
else \
\
echo "Warning: the subproject ${SUBPROJECT} does not have a \
bibliography." ; \
\
fi
endef

### ==================================================================
### Command for producing the PDF output of the subproject
### ==================================================================

## $1 = paper size (a4 / ipad), $2 = media type (print / screen)
define LATEXMK =
${ENVIRONMENT} \
latexmk \
-silent \
-output-directory='${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}' \
-e '$$$$biber="biber --input-encoding=UTF-8 \
--output-encoding=UTF-8 %O %S"' \
-pdfxe -pdfxelatex="xelatex -file-line-error -halt-on-error \
-interaction=nonstopmode -shell-escape -synctex=1 %O \
'\PassOptionsToClass{${$1_TYPE_SIZE},leqno,twoside}{article} \
\PassOptionsToPackage{outputdir=${PDF_DIRECTORY}/$1-$2/${SUBPROJECT}}{minted} \
\PassOptionsToPackage{papersize=$1,mediatype=$2}{basicnotes} \
\input{%S}'" \
${MAIN_LATEX_FILE}
endef

### ==================================================================
### Command for cleaning the bibliography of the subproject
### ==================================================================

define BIBCLEAN =
if [ -d ${BIBLIOGRAPHY_DIRECTORY} ] ; \
then \
cd ${BIBLIOGRAPHY_DIRECTORY} ; \
${RM} ${BIBLIOGRAPHY_RNC_SCHEMA} \
${BIBLIOGRAPHY_RNG_SCHEMA} \
${USED_ENTRIES_BIBLATEX_BIBLIOGRAPHY} \
${XML_BIBLIOGRAPHY} ; \
else \
echo "Warning: the subproject ${SUBPROJECT} does not have a \
bibliography" ; \
fi
endef

### ==================================================================
### Recipe for cleaning the output of the subproject
### ==================================================================

define CLEAN =
if [ -d ${BUILD_DIRECTORY} ] ; \
then \
cd ${BUILD_DIRECTORY} ; \
${RM} -r html/${SUBPROJECT} ; \
for i in ${PAPER_SIZES} ; \
do \
for j in ${MEDIA_TYPES}; \
do \
${RM} -r pdf/$${i}-$${j}/${SUBPROJECT} ; \
done ; \
done ; \
else \
true ; \
fi

if [ -d ${BUILD_DIRECTORY} ] ; \
then \
find ${BUILD_DIRECTORY} -type d -empty -delete ; \
else \
true ; \
fi
endef

### End of file
