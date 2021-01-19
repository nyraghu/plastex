.PHONY: all pdf

all: pdf

## $1 = paper size (a4 / ipad), $2 = media type (print / screen),
## psmt = paper size and media type
define psmt_TEMPLATE =
.PHONY pdf: $1-$2

.PHONY: ${PDF_DIRECTORY}/$1-$2/${MAIN_LATEX_FILE_STEM}.pdf

$1-$2: nix-build ${PDF_DIRECTORY}/$1-$2/${MAIN_LATEX_FILE_STEM}.pdf

${PDF_DIRECTORY}/$1-$2/${MAIN_LATEX_FILE_STEM}.pdf:
	@mkdir -p ${PDF_DIRECTORY}/$1-$2
	@$(call LATEXMK,$1,$2)
endef

$(foreach ps,${PAPER_SIZES},$(foreach \
	mt,${MEDIA_TYPES},$(eval $(call \
	psmt_TEMPLATE,${ps},${mt}))))
