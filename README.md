# Resume Build Commands

This repository currently exposes the following `make` targets.

## Available Commands

| Command | What it does | Outputs |
| --- | --- | --- |
| `make` | Runs the default target `all`. | Complete artifact set in `target/`, then published to `dist/` |
| `make all` | Builds every PDF, DOCX, and JSON artifact in `target/`, then copies final artifacts to `dist/`. | All committed deliverables in `dist/` |
| `make build` | Builds every artifact in the temporary output directory. | Complete artifact set in `target/` |
| `make publish` | Copies generated final artifacts from `target/` to `dist/`. | Complete artifact set in `dist/` |
| `make render-tex` | Renders the YAML data into TeX files without compiling PDFs. | Summary and resume `.tex` files in `target/` |
| `make tex2pdf` | Ensures TeX files are rendered and then runs `pdflatex` twice for each generated TeX file. | Summary and resume PDFs in `target/` |
| `make json` | Exports both full resumes to JSON Resume format. | `target/lebenslauf.json`, `target/resume.json` |
| `make summaries` | Builds and publishes the summary PDFs and DOCX files. | Summary PDFs and DOCX files in `dist/` |
| `make resumes` | Builds and publishes the full resume PDFs, DOCX files, and JSON files. | Full resume artifacts in `dist/` |
| `make lebenslauf` | Renders and compiles the full German resume PDF. | `dist/Torsten Uhlmann Lebenslauf.pdf` |
| `make resume` | Renders and compiles the full English resume PDF. | `dist/Torsten Uhlmann Resume.pdf` |
| `make lebenslauf-docx` | Exports the German full resume as ATS-style DOCX. | `dist/Torsten Uhlmann Lebenslauf.docx` |
| `make resume-docx` | Exports the English full resume as ATS-style DOCX. | `dist/Torsten Uhlmann Resume.docx` |
| `make docx` | Builds the summary DOCX files and both ATS-style full-resume DOCX files. | DOCX files in `target/` |
| `make docx-styled` | Builds both styled full-resume DOCX files. | Styled full-resume DOCX files in `target/` |
| `make assets-pdf` | Converts SVG and GIF assets for LaTeX PDF inclusion. | PDF asset derivatives next to files in `assets/` |
| `make clean` | Removes temporary generated output. | Deletes `target/` and the legacy `build/` directory |
| `make clean-dist` | Removes published deliverables. | Deletes `dist/` |

## What Gets Built

The current `Makefile` is wired to generate these summary assets:

- English summary from `data/summary-en.yaml`
- German summary from `data/summary-de.yaml`
- German full resume from `data/resume-de.yaml`
- English full resume from `data/resume-en.yaml`

Summary PDFs use `templates/summary.tex.j2` and `scripts/render.py`.
Full resume PDFs use `templates/resume.tex.j2`, `scripts/render.py`, and `scripts/render_svg.py`.
DOCX exports use `scripts/export_docx.py`.
JSON exports use `scripts/export_json_resume.py`.

All generated work happens in `target/`. The committed `dist/` directory is updated only by publish targets, including the default `make all` flow.

## Typical Usage

Build everything:

```sh
make all
```

Build everything into the temporary directory without publishing:

```sh
make build
```

Publish already-built artifacts:

```sh
make publish
```

Render only the intermediate TeX files:

```sh
make render-tex
```

Rebuild PDFs from the rendered TeX files:

```sh
make tex2pdf
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

- `target/` is the temporary build directory and is not committed.
- `dist/` contains the final committed artifacts.
- DOCX image conversion caches are stored under `target/docx-assets/`.
- `make clean` does not remove the tracked deliverables in `dist/`; use `make clean-dist` explicitly for that.