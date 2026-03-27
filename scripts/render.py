#!/usr/bin/env python3
"""Render resume YAML data through Jinja2 templates to produce TeX files."""

import argparse
import re
import sys
from pathlib import Path

import jinja2
import yaml


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


def build_env(template_dir: Path) -> jinja2.Environment:
    """Create a Jinja2 environment with TeX-friendly delimiters."""
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(str(template_dir)),
        # Use <<< >>> for variables and <<% %>> for blocks to avoid TeX conflicts
        variable_start_string="<<<",
        variable_end_string=">>>",
        comment_start_string="<<#",
        comment_end_string="#>>",
        # Blocks use a placeholder that we pre-process (see below)
        block_start_string="<<%",
        block_end_string="%>>",
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["tex_escape"] = tex_escape
    env.filters["tex_thinspace"] = tex_thinspace
    env.filters["tex_href"] = tex_href
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
