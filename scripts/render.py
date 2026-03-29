#!/usr/bin/env python3
"""Render resume YAML data through Jinja2 templates to produce TeX files."""

import argparse
import re
import sys
from copy import deepcopy
from datetime import datetime
from pathlib import Path

import jinja2
import yaml


MONTH_NAMES_DE = {
    1: "Jan.", 2: "Feb.", 3: "März", 4: "Apr.", 5: "Mai", 6: "Juni",
    7: "Juli", 8: "Aug.", 9: "Sep.", 10: "Okt.", 11: "Nov.", 12: "Dez.",
}
MONTH_NAMES_EN = {
    1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
    7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec",
}


def tex_escape(text: str) -> str:
    """Escape characters that are special in LaTeX."""
    replacements = {
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    # Don't escape braces or backslashes — they may be intentional TeX commands
    for char, replacement in replacements.items():
        text = text.replace(char, replacement)
    return text


PROSE_TEXT_KEYS = {
    "summary",
    "text",
    "description",
    "quote",
}

PROSE_LIST_KEYS = {
    "highlights",
}

NON_PROSE_KEYS = {
    "years",
    "start_date",
    "end_date",
    "date",
    "phone",
    "email",
    "url",
    "document",
    "photo",
    "logo",
    "pdf_title",
    "footer_url",
    "footer_url_text",
}


def prose_dashify(text: str, lang: str = "en") -> str:
    """Normalize semantic prose dashes by language.

    The content uses `---` as a semantic prose dash marker.
    English keeps the classic TeX/American em dash style (`---`).
    German renders it as a spaced en dash using nonbreaking thin spaces.
    """
    if not isinstance(text, str) or "---" not in text:
        return text
    if lang == "de":
        return text.replace("---", "~--~")
    return text


def normalize_prose_typography(value, lang: str = "en", key: str | None = None):
    """Recursively normalize language-aware prose typography in content data."""
    if isinstance(value, dict):
        normalized = {}
        for child_key, child_value in value.items():
            if child_key in NON_PROSE_KEYS:
                normalized[child_key] = child_value
            else:
                normalized[child_key] = normalize_prose_typography(
                    child_value, lang, child_key
                )
        return normalized

    if isinstance(value, list):
        if key in PROSE_LIST_KEYS:
            return [
                prose_dashify(item, lang) if isinstance(item, str)
                else normalize_prose_typography(item, lang)
                for item in value
            ]
        return [normalize_prose_typography(item, lang) for item in value]

    if isinstance(value, str) and key in PROSE_TEXT_KEYS:
        return prose_dashify(value, lang)

    return value


def tex_thinspace(text: str) -> str:
    """Replace ASCII patterns with TeX thin-space equivalents.

    Converts:
      +49 151 ... → +49\\,151\\,...
      2019--2024  → 2019\\,--\\,2024
      /           → \\,/\\,  (surrounded by spaces)
    """
    # Phone: digits separated by single spaces after a + prefix
    text = re.sub(r"(?<=\d) (?=\d)", r"\\,", text)
    # Year ranges: 2019--2024 → 2019\,--\,2024  (also handles 2025--present)
    text = re.sub(r"(\d)--(\d)", r"\1\\,--\\,\2", text)
    text = re.sub(r"(\d)--(\w)", r"\1\\,--\\,\2", text)
    # Slash separators with spaces: " / " → "\,/\,"
    text = text.replace(" / ", "\\,/\\,")
    return text


def tex_href(text: str) -> str:
    """Convert email addresses and phone numbers in text to TeX hyperlinks."""
    # Email — must be preceded by whitespace, start of string, or TeX dash (---)
    text = re.sub(
        r"(?<=\s)([\w.+-]+@[\w.-]+\.\w+)",
        r"\\href{mailto:\1}{\1}",
        text,
    )
    text = re.sub(
        r"^([\w.+-]+@[\w.-]+\.\w+)",
        r"\\href{mailto:\1}{\1}",
        text,
    )
    text = re.sub(
        r"(?<=---)([\w.+-]+@[\w.-]+\.\w+)",
        r"\\href{mailto:\1}{\1}",
        text,
    )
    # Phone: +49 151 ... pattern
    phone_match = re.search(r"(\+\d[\d ]+\d)", text)
    if phone_match:
        raw = phone_match.group(1)
        display = re.sub(r"(?<=\d) (?=\d)", r"\\,", raw)
        text = text.replace(raw, display)
    # TeX dashes
    text = text.replace("---", "---")
    return text


def fmt_date(value: str, lang: str = "en") -> str:
    """Format a YYYY-MM-DD or YYYY date string to 'Mon YYYY' or just 'YYYY'."""
    if not value:
        return ""
    s = str(value).strip()
    months = MONTH_NAMES_DE if lang == "de" else MONTH_NAMES_EN
    for fmt in ("%Y-%m-%d", "%Y-%m"):
        try:
            dt = datetime.strptime(s, fmt)
            return f"{months[dt.month]} {dt.year}"
        except ValueError:
            continue
    if re.fullmatch(r"\d{4}", s):
        return s
    return s


def fmt_date_range(start: str, end: str = "", lang: str = "en") -> str:
    """Format a date range like 'May 2019 -- Jul 2024' or 'Oct 2025 -- present'."""
    s = fmt_date(start, lang)
    if not end:
        present = "heute" if lang == "de" else "present"
        return f"{s}\\,--\\,{present}"
    e = fmt_date(end, lang)
    return f"{s}\\,--\\,{e}"


def fmt_year_range(start: str, end: str = "", lang: str = "en") -> str:
    """Format a year-only range like '2019 -- 2024' or '2025 -- present'."""
    sy = str(start)[:4] if start else ""
    ey = str(end)[:4] if end else ""
    if not ey:
        present = "heute" if lang == "de" else "present"
        return f"{sy}\\,--\\,{present}"
    if sy == ey:
        return sy
    return f"{sy}\\,--\\,{ey}"


def tech_join(techs: list) -> str:
    """Join a list of technology strings with TeX-friendly interpuncts."""
    escaped = [tex_escape(str(t)) for t in techs]
    return " \\enspace\\textperiodcentered\\enspace ".join(escaped)


def logo_path(path: str) -> str:
    """Convert an image path to a pdflatex-compatible format.

    SVG and GIF files are assumed to have been pre-converted to PDF by
    render_svg.py, so we swap the extension.
    """
    if not path:
        return path
    p = Path(path)
    if p.suffix.lower() in (".svg", ".gif"):
        return str(p.with_suffix(".pdf"))
    return path


def build_env(template_dir: Path) -> jinja2.Environment:
    """Create a Jinja2 environment with TeX-friendly delimiters."""
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(str(template_dir)),
        variable_start_string="<<<",
        variable_end_string=">>>",
        comment_start_string="<<#",
        comment_end_string="#>>",
        block_start_string="<<%",
        block_end_string="%>>",
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["tex_escape"] = tex_escape
    env.filters["tex_thinspace"] = tex_thinspace
    env.filters["tex_href"] = tex_href
    env.filters["fmt_date"] = fmt_date
    env.filters["fmt_date_range"] = fmt_date_range
    env.filters["fmt_year_range"] = fmt_year_range
    env.filters["tech_join"] = tech_join
    env.filters["logo_path"] = logo_path
    return env


def preprocess_template(text: str) -> str:
    """Convert the human-readable block markers to actual Jinja2 block delimiters.

    In the .j2 template we write:
        <<< block_open >>> ... <<< block_close >>>
    This function rewrites those to the real block delimiters <<% ... %>>
    so that the template author doesn't need to remember two delimiter styles.
    """
    text = text.replace("<<< block_open >>>", "<<%")
    text = text.replace("<<< block_close >>>", "%>>")
    return text


def render(data_path: Path, template_path: Path, output_path: Path) -> None:
    """Load data and template, render, and write output."""
    with open(data_path, encoding="utf-8") as f:
        data = yaml.safe_load(f)

    lang = str(data.get("meta", {}).get("language", "en")).strip().lower() or "en"
    data = normalize_prose_typography(deepcopy(data), lang)

    # Read raw template, preprocess block markers, then parse
    raw = template_path.read_text(encoding="utf-8")
    processed = preprocess_template(raw)

    env = build_env(template_path.parent)
    template = env.from_string(processed)

    rendered = template.render(**data)
    # Clean up trailing whitespace on lines and collapse multiple blank lines
    lines = rendered.split("\n")
    lines = [line.rstrip() for line in lines]
    rendered = "\n".join(lines)
    # Collapse 3+ consecutive newlines to 2
    rendered = re.sub(r"\n{3,}", "\n\n", rendered)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(rendered, encoding="utf-8")
    print(f"Rendered: {output_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Render resume templates")
    parser.add_argument("data", help="Path to YAML data file")
    parser.add_argument("template", help="Path to Jinja2 template")
    parser.add_argument("output", help="Path for rendered output file")
    args = parser.parse_args()

    render(
        data_path=Path(args.data),
        template_path=Path(args.template),
        output_path=Path(args.output),
    )


if __name__ == "__main__":
    main()
