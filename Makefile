.PHONY: all build publish render-tex tex2pdf json clean clean-dist assets-pdf summaries resumes cover-letters summary-docx lebenslauf resume lebenslauf-docx resume-docx lebenslauf-docx-styled resume-docx-styled docx docx-styled

PYTHON   := .venv/bin/python
RENDER   := scripts/render.py
SVG      := scripts/render_svg.py
DOCX     := scripts/export_docx.py
JSON     := scripts/export_json_resume.py
SUMMARY_TEMPLATE := templates/summary.tex.j2
RESUME_TEMPLATE  := templates/resume.tex.j2
COVER_LETTER_TEMPLATE := templates/cover-letter.tex.j2

DATA_DIR := data
OUT_DIR  := target
DIST_DIR  := dist

# Summary outputs
SUMMARY_TEX := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex

SUMMARY_PDF := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.pdf \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.pdf

SUMMARY_DOCX := \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx \
	$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx

SUMMARY_DIST := \
	$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Summary.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx

# Full resume outputs
RESUME_DE_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf.tex
RESUME_EN_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Resume.tex

RESUME_DE_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf.pdf
RESUME_EN_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Resume.pdf

RESUME_DE_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf.docx
RESUME_EN_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Resume.docx
RESUME_DE_DOCX_STYLED := $(OUT_DIR)/Torsten\ Uhlmann\ Lebenslauf\ Styled.docx
RESUME_EN_DOCX_STYLED := $(OUT_DIR)/Torsten\ Uhlmann\ Resume\ Styled.docx

RESUME_DE_JSON := $(OUT_DIR)/lebenslauf.json
RESUME_EN_JSON := $(OUT_DIR)/resume.json

RESUME_DIST := \
	$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Resume.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Resume.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf\ Styled.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Resume\ Styled.docx \
	$(DIST_DIR)/lebenslauf.json \
	$(DIST_DIR)/resume.json

# Cover letter outputs
COVER_LETTER_DE_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben.tex
COVER_LETTER_EN_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Cover\ Letter.tex
COVER_LETTER_INES_SCHOLZ_DE_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.tex
COVER_LETTER_HAUFE_GROUP_DE_TEX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.tex

COVER_LETTER_DE_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben.pdf
COVER_LETTER_EN_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Cover\ Letter.pdf
COVER_LETTER_INES_SCHOLZ_DE_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.pdf
COVER_LETTER_HAUFE_GROUP_DE_PDF := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.pdf

COVER_LETTER_DE_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben.docx
COVER_LETTER_EN_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Cover\ Letter.docx
COVER_LETTER_INES_SCHOLZ_DE_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.docx
COVER_LETTER_HAUFE_GROUP_DE_DOCX := $(OUT_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.docx

COVER_LETTER_DIST := \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Cover\ Letter.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.pdf \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Cover\ Letter.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.docx \
	$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.docx

TARGET_ARTIFACTS := $(SUMMARY_PDF) $(SUMMARY_DOCX) $(RESUME_DE_PDF) $(RESUME_EN_PDF) $(RESUME_DE_DOCX) $(RESUME_EN_DOCX) $(RESUME_DE_DOCX_STYLED) $(RESUME_EN_DOCX_STYLED) $(RESUME_DE_JSON) $(RESUME_EN_JSON) $(COVER_LETTER_DE_PDF) $(COVER_LETTER_EN_PDF) $(COVER_LETTER_INES_SCHOLZ_DE_PDF) $(COVER_LETTER_HAUFE_GROUP_DE_PDF) $(COVER_LETTER_DE_DOCX) $(COVER_LETTER_EN_DOCX) $(COVER_LETTER_INES_SCHOLZ_DE_DOCX) $(COVER_LETTER_HAUFE_GROUP_DE_DOCX)
DIST_ARTIFACTS := $(SUMMARY_DIST) $(RESUME_DIST) $(COVER_LETTER_DIST)

all: publish

build: $(TARGET_ARTIFACTS)

publish: $(DIST_ARTIFACTS)

# ---- Render YAML → TeX ----
render-tex: $(SUMMARY_TEX) $(RESUME_DE_TEX) $(RESUME_EN_TEX) $(COVER_LETTER_DE_TEX) $(COVER_LETTER_EN_TEX) $(COVER_LETTER_INES_SCHOLZ_DE_TEX) $(COVER_LETTER_HAUFE_GROUP_DE_TEX)

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex: $(DATA_DIR)/summary-en.yaml $(SUMMARY_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/summary-en.yaml" "$(SUMMARY_TEMPLATE)" "$@"

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex: $(DATA_DIR)/summary-de.yaml $(SUMMARY_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/summary-de.yaml" "$(SUMMARY_TEMPLATE)" "$@"

$(RESUME_DE_TEX): $(DATA_DIR)/resume-de.yaml $(RESUME_TEMPLATE) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-de.yaml" "$(RESUME_TEMPLATE)" "$@"

$(RESUME_EN_TEX): $(DATA_DIR)/resume-en.yaml $(RESUME_TEMPLATE) $(RENDER) | $(BUILD_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/resume-en.yaml" "$(RESUME_TEMPLATE)" "$@"

$(COVER_LETTER_DE_TEX): $(DATA_DIR)/cover-letter-de.yaml $(COVER_LETTER_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/cover-letter-de.yaml" "$(COVER_LETTER_TEMPLATE)" "$@"

$(COVER_LETTER_EN_TEX): $(DATA_DIR)/cover-letter-en.yaml $(COVER_LETTER_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/cover-letter-en.yaml" "$(COVER_LETTER_TEMPLATE)" "$@"

$(COVER_LETTER_INES_SCHOLZ_DE_TEX): $(DATA_DIR)/cover-letter-de.yaml $(DATA_DIR)/applications/ines-scholz-de.yaml $(COVER_LETTER_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/cover-letter-de.yaml" "$(COVER_LETTER_TEMPLATE)" "$@" --override "$(DATA_DIR)/applications/ines-scholz-de.yaml"

$(COVER_LETTER_HAUFE_GROUP_DE_TEX): $(DATA_DIR)/cover-letter-de.yaml $(DATA_DIR)/applications/haufe-group-de.yaml $(COVER_LETTER_TEMPLATE) $(RENDER) | $(OUT_DIR)
	$(PYTHON) $(RENDER) "$(DATA_DIR)/cover-letter-de.yaml" "$(COVER_LETTER_TEMPLATE)" "$@" --override "$(DATA_DIR)/applications/haufe-group-de.yaml"

# ---- TeX → PDF ----
tex2pdf: $(SUMMARY_PDF) $(RESUME_DE_PDF) $(RESUME_EN_PDF) $(COVER_LETTER_DE_PDF) $(COVER_LETTER_EN_PDF) $(COVER_LETTER_INES_SCHOLZ_DE_PDF) $(COVER_LETTER_HAUFE_GROUP_DE_PDF)

assets-pdf:
	$(PYTHON) $(SVG)

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.pdf: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.tex assets-pdf
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann CV Summary.tex" && pdflatex "Torsten Uhlmann CV Summary.tex")

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.pdf: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.tex assets-pdf
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann CV Übersicht.tex" && pdflatex "Torsten Uhlmann CV Übersicht.tex")

$(RESUME_DE_PDF): $(RESUME_DE_TEX) assets-pdf
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Lebenslauf.tex" && pdflatex "Torsten Uhlmann Lebenslauf.tex")

$(RESUME_EN_PDF): $(RESUME_EN_TEX) assets-pdf
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Resume.tex" && pdflatex "Torsten Uhlmann Resume.tex")

$(COVER_LETTER_DE_PDF): $(COVER_LETTER_DE_TEX)
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Anschreiben.tex" && pdflatex "Torsten Uhlmann Anschreiben.tex")

$(COVER_LETTER_EN_PDF): $(COVER_LETTER_EN_TEX)
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Cover Letter.tex" && pdflatex "Torsten Uhlmann Cover Letter.tex")

$(COVER_LETTER_INES_SCHOLZ_DE_PDF): $(COVER_LETTER_INES_SCHOLZ_DE_TEX)
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Anschreiben Ines Scholz.tex" && pdflatex "Torsten Uhlmann Anschreiben Ines Scholz.tex")

$(COVER_LETTER_HAUFE_GROUP_DE_PDF): $(COVER_LETTER_HAUFE_GROUP_DE_TEX)
	(cd "$(OUT_DIR)" && pdflatex "Torsten Uhlmann Anschreiben Haufe Group.tex" && pdflatex "Torsten Uhlmann Anschreiben Haufe Group.tex")

# ---- YAML → DOCX ----
$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx: $(DATA_DIR)/summary-en.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/summary-en.yaml" "$@" --style styled

$(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx: $(DATA_DIR)/summary-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/summary-de.yaml" "$@" --style styled

$(RESUME_DE_DOCX): $(DATA_DIR)/resume-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-de.yaml" "$@" --style ats

$(RESUME_EN_DOCX): $(DATA_DIR)/resume-en.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-en.yaml" "$@" --style ats

$(RESUME_DE_DOCX_STYLED): $(DATA_DIR)/resume-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-de.yaml" "$@" --style styled

$(RESUME_EN_DOCX_STYLED): $(DATA_DIR)/resume-en.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/resume-en.yaml" "$@" --style styled

$(COVER_LETTER_DE_DOCX): $(DATA_DIR)/cover-letter-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/cover-letter-de.yaml" "$@" --style styled

$(COVER_LETTER_EN_DOCX): $(DATA_DIR)/cover-letter-en.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/cover-letter-en.yaml" "$@" --style styled

$(COVER_LETTER_INES_SCHOLZ_DE_DOCX): $(DATA_DIR)/cover-letter-de.yaml $(DATA_DIR)/applications/ines-scholz-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/cover-letter-de.yaml" "$@" --style styled --override "$(DATA_DIR)/applications/ines-scholz-de.yaml"

$(COVER_LETTER_HAUFE_GROUP_DE_DOCX): $(DATA_DIR)/cover-letter-de.yaml $(DATA_DIR)/applications/haufe-group-de.yaml $(DOCX) | $(OUT_DIR)
	$(PYTHON) $(DOCX) "$(DATA_DIR)/cover-letter-de.yaml" "$@" --style styled --override "$(DATA_DIR)/applications/haufe-group-de.yaml"

# ---- YAML → JSON Resume ----
json: $(RESUME_DE_JSON) $(RESUME_EN_JSON)

$(RESUME_DE_JSON): $(DATA_DIR)/resume-de.yaml $(JSON) | $(OUT_DIR)
	$(PYTHON) $(JSON) "$(DATA_DIR)/resume-de.yaml" "$@"

$(RESUME_EN_JSON): $(DATA_DIR)/resume-en.yaml $(JSON) | $(OUT_DIR)
	$(PYTHON) $(JSON) "$(DATA_DIR)/resume-en.yaml" "$@"

# ---- Publish target artifacts ----
$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Summary.pdf: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.pdf | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.pdf: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.pdf | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.pdf: $(RESUME_DE_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Resume.pdf: $(RESUME_EN_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.docx: $(RESUME_DE_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Resume.docx: $(RESUME_EN_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf\ Styled.docx: $(RESUME_DE_DOCX_STYLED) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Resume\ Styled.docx: $(RESUME_EN_DOCX_STYLED) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/lebenslauf.json: $(RESUME_DE_JSON) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/resume.json: $(RESUME_EN_JSON) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben.pdf: $(COVER_LETTER_DE_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Cover\ Letter.pdf: $(COVER_LETTER_EN_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.pdf: $(COVER_LETTER_INES_SCHOLZ_DE_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.pdf: $(COVER_LETTER_HAUFE_GROUP_DE_PDF) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben.docx: $(COVER_LETTER_DE_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Cover\ Letter.docx: $(COVER_LETTER_EN_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Ines\ Scholz.docx: $(COVER_LETTER_INES_SCHOLZ_DE_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

$(DIST_DIR)/Torsten\ Uhlmann\ Anschreiben\ Haufe\ Group.docx: $(COVER_LETTER_HAUFE_GROUP_DE_DOCX) | $(DIST_DIR)
	cp "$<" "$@"

summaries: $(SUMMARY_DIST)

resumes: $(RESUME_DIST)

cover-letters: $(COVER_LETTER_DIST)

summary-docx: $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Summary.docx $(OUT_DIR)/Torsten\ Uhlmann\ CV\ Übersicht.docx

lebenslauf: $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.pdf

resume: $(DIST_DIR)/Torsten\ Uhlmann\ Resume.pdf

lebenslauf-docx: $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf.docx

resume-docx: $(DIST_DIR)/Torsten\ Uhlmann\ Resume.docx

lebenslauf-docx-styled: $(DIST_DIR)/Torsten\ Uhlmann\ Lebenslauf\ Styled.docx

resume-docx-styled: $(DIST_DIR)/Torsten\ Uhlmann\ Resume\ Styled.docx

docx: $(SUMMARY_DOCX) $(RESUME_DE_DOCX) $(RESUME_EN_DOCX) $(COVER_LETTER_DE_DOCX) $(COVER_LETTER_EN_DOCX) $(COVER_LETTER_INES_SCHOLZ_DE_DOCX) $(COVER_LETTER_HAUFE_GROUP_DE_DOCX)

docx-styled: $(RESUME_DE_DOCX_STYLED) $(RESUME_EN_DOCX_STYLED) $(COVER_LETTER_DE_DOCX) $(COVER_LETTER_EN_DOCX) $(COVER_LETTER_INES_SCHOLZ_DE_DOCX) $(COVER_LETTER_HAUFE_GROUP_DE_DOCX)

$(OUT_DIR):
	mkdir -p "$(OUT_DIR)"

$(DIST_DIR):
	mkdir -p "$(DIST_DIR)"

clean:
	rm -rf "$(OUT_DIR)"
	rm -rf "build"

clean-dist:
	rm -rf "$(DIST_DIR)"
