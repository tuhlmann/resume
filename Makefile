.PHONY: all summary resume json render pdf assets clean

PYTHON       := .venv/bin/python
RENDER       := scripts/render.py
SUMMARY_TPL  := templates/summary.tex.j2
RESUME_TPL   := templates/resume.tex.j2
JSON_EXPORT  := scripts/export_json_resume.py
SVG_CONVERT  := scripts/render_svg.py

DATA_DIR := data
OUT_DIR  := target

# ---- Summary (1-page) targets ----
SUMMARY_TARGETS := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex

# ---- Full resume targets ----
RESUME_TARGETS := \
	$(OUT_DIR)/Torsten\ Uhlmann\ Resume.tex \
	$(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex

all: summary resume json pdf

# ---- Render Summary YAML → TeX ----
summary: $(SUMMARY_TARGETS)

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex: $(DATA_DIR)/en.yaml $(SUMMARY_TPL) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/en.yaml" "$(SUMMARY_TPL)" "$@"

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex: $(DATA_DIR)/de.yaml $(SUMMARY_TPL) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/de.yaml" "$(SUMMARY_TPL)" "$@"

# ---- Render Full Resume YAML → TeX ----
resume: $(RESUME_TARGETS)

$(OUT_DIR)/Torsten\ Uhlmann\ Resume.tex: $(DATA_DIR)/resume-en.yaml $(RESUME_TPL) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-en.yaml" "$(RESUME_TPL)" "$@"

$(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex: $(DATA_DIR)/resume-de.yaml $(RESUME_TPL) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-de.yaml" "$(RESUME_TPL)" "$@"

# ---- Export JSON Resume ----
json: | $(OUT_DIR)
	$(PYTHON) $(JSON_EXPORT) "$(DATA_DIR)/resume-en.yaml" "$(OUT_DIR)/resume.json"
	$(PYTHON) $(JSON_EXPORT) "$(DATA_DIR)/resume-de.yaml" "$(OUT_DIR)/lebenslauf.json"

# ---- Render (backward compat alias) ----
render: summary resume

# ---- Convert SVG/GIF assets → PDF ----
assets:
	$(PYTHON) $(SVG_CONVERT)

# ---- TeX → PDF ----
pdf: assets summary resume
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
