SOURCE_DIRECTORY = src
MAIN_LATEX_FILE = ${SOURCE_DIRECTORY}/main.tex
MAIN_LATEX_FILE_STEM = $(notdir $(basename ${MAIN_LATEX_FILE}))

BUILD_DIRECTORY = build
HTML_DIRECTORY = ${BUILD_DIRECTORY}/html
PDF_DIRECTORY = ${BUILD_DIRECTORY}/pdf

MATHJAX_URL = js/mathjax/tex-chtml.js
MAIN_HTML_FILE = ${HTML_DIRECTORY}/index.html

FONTS_DIRECTORY = result/share/fonts
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

BIBLIOGRAPHY_DIRECTORY = ${CURDIR}/bibliography
BIBLATEX_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}.bib
XML_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}.bltxml
BIBLIOGRAPHY_RNG_SCHEMA = ${MAIN_LATEX_FILE_STEM}.rng
BIBLIOGRAPHY_RNC_SCHEMA = ${MAIN_LATEX_FILE_STEM}.rnc
BIBER_CONTROL_FILE = ${MAIN_LATEX_FILE_STEM}.bcf
USED_ENTRIES_BIBLATEX_BIBLIOGRAPHY = ${MAIN_LATEX_FILE_STEM}_used.bib

define TEXMF_SOURCE_FILES =
$(shell find ${SOURCE_DIRECTORY} -name '*.tex') \
${BIBLIOGRAPHY_DIRECTORY}/${BIBLATEX_BIBLIOGRAPHY}
endef

define ENVIRONMENT =
SOURCE_DATE_EPOCH=0 \
FORCE_SOURCE_DATE=1 \
LOCALE_ARCHIVE=result/lib/locale/locale-archive \
BLTXMLINPUTS=${BIBLIOGRAPHY_DIRECTORY}//: \
BIBINPUTS=${BIBLIOGRAPHY_DIRECTORY}//: \
TEXFONTS=${TEXFONTS}:
endef

PAPER_SIZES = a4 ipad
MEDIA_TYPES = print screen

a4_TYPE_SIZE = 11pt
ipad_TYPE_SIZE = 10pt

define GENERATE_XML_BIBLIOGRAPHY =
mkdir -p ${HTML_DIRECTORY}
${ENVIRONMENT} biber \
--input-directory=${PDF_DIRECTORY}/ipad-screen \
--output-directory=${PDF_DIRECTORY}/ipad-screen \
--input-encoding=UTF-8 \
--output-encoding=UTF-8 \
--output-file=${BIBLATEX_BIBLIOGRAPHY} \
--output-format=bibtex \
${BIBER_CONTROL_FILE}

${ENVIRONMENT} biber \
--input-directory=${PDF_DIRECTORY}/ipad-screen \
--output-directory=${PDF_DIRECTORY}/ipad-screen \
--input-encoding=UTF-8 \
--output-encoding=UTF-8 \
--output-file=${XML_BIBLIOGRAPHY} \
--output-format=biblatexml \
--output-resolve-xdata \
--tool \
${BIBLATEX_BIBLIOGRAPHY}

cp ${PDF_DIRECTORY}/ipad-screen/${BIBLATEX_BIBLIOGRAPHY} \
${BIBLIOGRAPHY_DIRECTORY}/${USED_ENTRIES_BIBLATEX_BIBLIOGRAPHY}

cp ${PDF_DIRECTORY}/ipad-screen/${XML_BIBLIOGRAPHY} \
${BIBLIOGRAPHY_DIRECTORY}/${XML_BIBLIOGRAPHY}

cp ${PDF_DIRECTORY}/ipad-screen/${BIBLIOGRAPHY_RNG_SCHEMA}\
${BIBLIOGRAPHY_DIRECTORY}/${BIBLIOGRAPHY_RNG_SCHEMA}
endef

define GENERATE_BIBLIOGRAPHY_RNC_SCHEMA =
cd ${BIBLIOGRAPHY_DIRECTORY} ; \
trang ${BIBLIOGRAPHY_RNG_SCHEMA} ${BIBLIOGRAPHY_RNC_SCHEMA}
endef

define PLASTEX =
${ENVIRONMENT} plastex \
--dir=${HTML_DIRECTORY} \
--renderer=HTMLNotes \
--html-notes-mathjax-url='${MATHJAX_URL}' \
${MAIN_LATEX_FILE}
@${RM} main.paux
@echo
endef

TIDY_COOKIE = ${BUILD_DIRECTORY}/html/.tidy_DONE

define TIDY =
tidy \
--fix-uri no \
--quiet yes \
--tidy-mark no \
--wrap 0 \
--write-back yes \
${HTML_DIRECTORY}/*.html

touch ${TIDY_COOKIE}
endef

VALIDATE_HTML = nu-html-checker ${HTML_DIRECTORY}/*.html

## $1 = paper size (a4 / ipad), $2 = media type (print / screen)
define LATEXMK =
${ENVIRONMENT} latexmk \
-silent \
-output-directory='${PDF_DIRECTORY}/$1-$2' \
-e '$$$$biber="biber --input-encoding=UTF-8 \
--output-encoding=UTF-8 %O %S"' \
-pdfxe -xelatex="xelatex -file-line-error -halt-on-error \
-interaction=nonstopmode -shell-escape -synctex=1 %O \
'\PassOptionsToClass{${$1_TYPE_SIZE},leqno,twoside}{article} \
\PassOptionsToPackage{outputdir=${PDF_DIRECTORY}/$1-$2}{minted} \
\PassOptionsToPackage{papersize=$1,mediatype=$2}{basicnotes} \
\input{%S}'" \
${MAIN_LATEX_FILE}
endef

define BIBCLEAN =
cd ${BIBLIOGRAPHY_DIRECTORY} ; \
${RM} main.bltxml main_used.bib main.rng main.rnc
endef

NIX_BUILD_COOKIE = .nix_build_DONE

.DEFAULT_GOAL = all
