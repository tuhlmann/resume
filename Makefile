.PHONY: all render pdf clean assets-pdf lebenslauf resume lebenslauf-docx resume-docx lebenslauf-docx-styled resume-docx-styled docx docx-styled

PYTHON   := .venv/bin/python
RENDER   := scripts/render.py
SVG      := scripts/render_svg.py
DOCX     := scripts/export_docx.py
SUMMARY_TEMPLATE := templates/summary.tex.j2
RESUME_TEMPLATE  := templates/resume.tex.j2

DATA_DIR := data
OUT_DIR  := target
BUILD_DIR := build
DIST_DIR  := dist

# Map data files to output TeX names
TARGETS := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex

RESUME_DE_TEX := $(BUILD_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex
RESUME_EN_TEX := $(BUILD_DIR)/Torsten\ Uhlmann\ Resume.tex

RESUME_DE_PDF := $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.pdf
RESUME_EN_PDF := $(DIST_DIR)/Torsten\ Uhlmann\ Resume.pdf

RESUME_DE_DOCX := $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.docx
RESUME_EN_DOCX := $(DIST_DIR)/Torsten\ Uhlmann\ Resume.docx
RESUME_DE_DOCX_STYLED := $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf\ Styled.docx
RESUME_EN_DOCX_STYLED := $(DIST_DIR)/Torsten\ Uhlmann\ Resume\ Styled.docx

all: render pdf

# ---- Render YAML → TeX ----
render: $(TARGETS)

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex: $(DATA_DIR)/summary-en.yaml $(SUMMARY_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/summary-en.yaml" "$(SUMMARY_TEMPLATE)" "$@"

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex: $(DATA_DIR)/summary-de.yaml $(SUMMARY_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/summary-de.yaml" "$(SUMMARY_TEMPLATE)" "$@"

$(RESUME_DE_TEX): $(DATA_DIR)/resume-de.yaml $(RESUME_TEMPLATE) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-de.yaml" "$(RESUME_TEMPLATE)" "$@"

$(RESUME_EN_TEX): $(DATA_DIR)/resume-en.yaml $(RESUME_TEMPLATE) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-en.yaml" "$(RESUME_TEMPLATE)" "$@"

# ---- TeX → PDF ----
pdf: render
	@find "$(OUT_DIR)" -maxdepth 1 -name '*.tex' -print | while IFS= read -r f; do \
		base="$$(basename "$$f")"; \
		echo "Building: $$base"; \
		(cd "$(OUT_DIR)" && pdflatex "$$base" && pdflatex "$$base"); \
	done

assets-pdf:
	$(PYTHON) $(SVG)

$(RESUME_DE_PDF): $(RESUME_DE_TEX) assets-pdf | $(DIST_DIR)
	(cd "$(BUILD_DIR)" && pdflatex "Torsten Uhlmann Lebenslauf.tex" && pdflatex "Torsten Uhlmann Lebenslauf.tex"); \
	cp "$(BUILD_DIR)/Torsten Uhlmann Lebenslauf.pdf" "$@"

$(RESUME_EN_PDF): $(RESUME_EN_TEX) assets-pdf | $(DIST_DIR)
	(cd "$(BUILD_DIR)" && pdflatex "Torsten Uhlmann Resume.tex" && pdflatex "Torsten Uhlmann Resume.tex"); \
	cp "$(BUILD_DIR)/Torsten Uhlmann Resume.pdf" "$@"

lebenslauf: $(RESUME_DE_PDF)

resume: $(RESUME_EN_PDF)

$(RESUME_DE_DOCX): $(DATA_DIR)/resume-de.yaml $(DOCX) | $(DIST_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-de.yaml" "$@" --style ats

$(RESUME_EN_DOCX): $(DATA_DIR)/resume-en.yaml $(DOCX) | $(DIST_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-en.yaml" "$@" --style ats

$(RESUME_DE_DOCX_STYLED): $(DATA_DIR)/resume-de.yaml $(DOCX) | $(DIST_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-de.yaml" "$@" --style styled

$(RESUME_EN_DOCX_STYLED): $(DATA_DIR)/resume-en.yaml $(DOCX) | $(DIST_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-en.yaml" "$@" --style styled

lebenslauf-docx: $(RESUME_DE_DOCX)

resume-docx: $(RESUME_EN_DOCX)

docx: $(RESUME_DE_DOCX) $(RESUME_EN_DOCX)

docx-styled: $(RESUME_DE_DOCX_STYLED) $(RESUME_EN_DOCX_STYLED)

$(OUT_DIR):
	mkdir -p "$(OUT_DIR)"

$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

$(DIST_DIR):
	mkdir -p "$(DIST_DIR)"

clean:
	rm -rf "$(OUT_DIR)"
	rm -f "$(BUILD_DIR)"/*.tex "$(BUILD_DIR)"/*.pdf
	rm -f "$(BUILD_DIR)"/*.aux "$(BUILD_DIR)"/*.log "$(BUILD_DIR)"/*.out "$(BUILD_DIR)"/*.toc "$(BUILD_DIR)"/*.bkm
