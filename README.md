# Resume Build Commands

This repository currently exposes the following `make` targets.

## Available Commands

| Command | What it does | Outputs |
| --- | --- | --- |
| `make` | Runs the default target `all`. | Rendered `.tex` files and PDFs in `target/` |
| `make all` | Renders the TeX files and then builds PDFs. | `target/Torsten Uhlmann CV Summary.tex`, `target/Torsten Uhlmann CV Übersicht.tex`, plus matching PDFs |
| `make render` | Renders the YAML data into TeX files without compiling PDFs. | `target/Torsten Uhlmann CV Summary.tex`, `target/Torsten Uhlmann CV Übersicht.tex` |
| `make pdf` | Ensures TeX files are rendered and then runs `pdflatex` twice for each generated TeX file. | PDFs in `target/` for each generated TeX file |
| `make lebenslauf` | Renders and compiles the full German resume PDF. | `dist/Torsten Uhlmann Lebenslauf.pdf` |
| `make resume` | Renders and compiles the full English resume PDF. | `dist/Torsten Uhlmann Resume.pdf` |
| `make lebenslauf-docx` | Exports the German full resume as ATS-style DOCX. | `dist/Torsten Uhlmann Lebenslauf.docx` |
| `make resume-docx` | Exports the English full resume as ATS-style DOCX. | `dist/Torsten Uhlmann Resume.docx` |
| `make docx` | Builds both ATS-style full-resume DOCX files. | `dist/Torsten Uhlmann Lebenslauf.docx`, `dist/Torsten Uhlmann Resume.docx` |
| `make docx-styled` | Builds both styled full-resume DOCX files. | `dist/Torsten Uhlmann Lebenslauf Styled.docx`, `dist/Torsten Uhlmann Resume Styled.docx` |
| `make assets-pdf` | Converts SVG and GIF assets for LaTeX PDF inclusion. | PDF asset derivatives next to files in `assets/` |
| `make clean` | Removes generated summary output and full-resume LaTeX intermediates. | Deletes `target/` and generated `.tex/.pdf/.aux/.log/...` files in `build/` |

## What Gets Built

The current `Makefile` is wired to generate these summary assets:

- English summary from `data/summary-en.yaml`
- German summary from `data/summary-de.yaml`
- German full resume from `data/resume-de.yaml`
- English full resume from `data/resume-en.yaml`

Summary PDFs use `templates/summary.tex.j2` and `scripts/render.py`.
Full resume PDFs use `templates/resume.tex.j2`, `scripts/render.py`, and `scripts/render_svg.py`.
DOCX exports use `scripts/export_docx.py`.

## Typical Usage

Build everything:

```sh
make all
```

Render only the intermediate TeX files:

```sh
make render
```

Rebuild PDFs from the rendered TeX files:

```sh
make pdf
```

Build the German full resume PDF:

```sh
make lebenslauf
```

Build both full-resume DOCX files:

```sh
make docx
```

Build the styled DOCX variants:

```sh
make docx-styled
```

Remove generated summary output and LaTeX intermediates:

```sh
make clean
```

## Notes

- `make all` still builds only the summary PDF flow.
- The full resume PDF targets write intermediate TeX files to `build/` and final PDFs to `dist/`.
- The DOCX targets export the full resume variants, not the short summaries.
- `make clean` does not remove the tracked deliverables in `dist/`.