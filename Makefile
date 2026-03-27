.PHONY: all render pdf clean

PYTHON   := .venv/bin/python
RENDER   := scripts/render.py
TEMPLATE := templates/summary.tex.j2

DATA_DIR := data
OUT_DIR  := target

# Map data files to output TeX names
TARGETS := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex

all: render pdf

# ---- Render YAML → TeX ----
render: $(TARGETS)

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex: $(DATA_DIR)/en.yaml $(TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/en.yaml" "$(TEMPLATE)" "$@"

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex: $(DATA_DIR)/de.yaml $(TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/de.yaml" "$(TEMPLATE)" "$@"

# ---- TeX → PDF ----
pdf: render
	@find "$(OUT_DIR)" -maxdepth 1 -name '*.tex' -print | while IFS= read -r f; do \
		base="$$(basename "$$f")"; \
		echo "Building: $$base"; \
		(cd "$(OUT_DIR)" && pdflatex "$$base" && pdflatex "$$base"); \
	done

$(OUT_DIR):
	mkdir -p "$(OUT_DIR)"

clean:
	rm -rf "$(OUT_DIR)"
	rm -f "$(SRC_DIR)"/*.aux "$(SRC_DIR)"/*.log "$(SRC_DIR)"/*.out "$(SRC_DIR)"/*.toc "$(SRC_DIR)"/*.bkm
