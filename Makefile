.PHONY: all summary resume json docx render pdf assets clean distclean

PYTHON       := .venv/bin/python
RENDER       := scripts/render.py
SUMMARY_TPL  := templates/summary.tex.j2
RESUME_TPL   := templates/resume.tex.j2
JSON_EXPORT  := scripts/export_json_resume.py
DOCX_EXPORT  := scripts/export_docx.py
SVG_CONVERT  := scripts/render_svg.py

DATA_DIR  := data
BUILD_DIR := build
DIST_DIR  := dist

# ---- Summary (1-page) targets ----
SUMMARY_TARGETS := \
	$(BUILD_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex \
	$(BUILD_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex

# ---- Full resume targets ----
RESUME_TARGETS := \
	$(BUILD_DIR)/Torsten\ Uhlmann\ Resume.tex \
	$(BUILD_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex

all: summary resume json docx pdf

# ---- Render Summary YAML → TeX ----
summary: $(SUMMARY_TARGETS)

$(BUILD_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex: $(DATA_DIR)/en.yaml $(SUMMARY_TPL) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/en.yaml" "$(SUMMARY_TPL)" "$@"

$(BUILD_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex: $(DATA_DIR)/de.yaml $(SUMMARY_TPL) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/de.yaml" "$(SUMMARY_TPL)" "$@"

# ---- Render Full Resume YAML → TeX ----
resume: $(RESUME_TARGETS)

$(BUILD_DIR)/Torsten\ Uhlmann\ Resume.tex: $(DATA_DIR)/resume-en.yaml $(RESUME_TPL) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-en.yaml" "$(RESUME_TPL)" "$@"

$(BUILD_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex: $(DATA_DIR)/resume-de.yaml $(RESUME_TPL) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-de.yaml" "$(RESUME_TPL)" "$@"

# ---- Export JSON Resume ----
json: | $(DIST_DIR)
	$(PYTHON) $(JSON_EXPORT) "$(DATA_DIR)/resume-en.yaml" "$(DIST_DIR)/resume.json"
	$(PYTHON) $(JSON_EXPORT) "$(DATA_DIR)/resume-de.yaml" "$(DIST_DIR)/lebenslauf.json"

# ---- Export DOCX ----
docx: | $(BUILD_DIR) $(DIST_DIR)
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/resume-en.yaml" "$(DIST_DIR)/Torsten Uhlmann Resume.docx" --style ats
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/resume-en.yaml" "$(DIST_DIR)/Torsten Uhlmann Resume Styled.docx" --style styled
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/resume-de.yaml" "$(DIST_DIR)/Torsten Uhlmann Lebenslauf.docx" --style ats
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/resume-de.yaml" "$(DIST_DIR)/Torsten Uhlmann Lebenslauf Styled.docx" --style styled
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/en.yaml" "$(DIST_DIR)/Torsten Uhlmann CV Summary.docx" --style styled
	$(PYTHON) $(DOCX_EXPORT) "$(DATA_DIR)/de.yaml" "$(DIST_DIR)/Torsten Uhlmann CV Übersicht.docx" --style styled

# ---- Render (backward compat alias) ----
render: summary resume

# ---- Convert SVG/GIF assets → PDF ----
assets:
	$(PYTHON) $(SVG_CONVERT)

# ---- TeX → PDF ----
pdf: assets summary resume | $(DIST_DIR)
	@find "$(BUILD_DIR)" -maxdepth 1 -name '*.tex' -print | while IFS= read -r f; do \
		base="$$(basename "$$f")"; \
		pdf="$${base%.tex}.pdf"; \
		echo "Building: $$base"; \
		(cd "$(BUILD_DIR)" && pdflatex "$$base" && pdflatex "$$base"); \
		cp "$(BUILD_DIR)/$$pdf" "$(DIST_DIR)/$$pdf"; \
	done

$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

$(DIST_DIR):
	mkdir -p "$(DIST_DIR)"

clean:
	rm -rf "$(BUILD_DIR)"

distclean:
	rm -rf "$(BUILD_DIR)" "$(DIST_DIR)"
