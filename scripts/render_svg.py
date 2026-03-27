"""Convert SVG (and GIF) images in assets/ to PDF so pdflatex can include them.

Requires ``rsvg-convert`` (from librsvg) for SVGs and ``sips`` (macOS built-in)
for GIFs.  Outputs are placed next to the source file with a .pdf extension.
Only files that are newer than their PDF counterpart are re-rendered.

Usage::

    python scripts/render_svg.py            # convert all
    python scripts/render_svg.py --force    # re-convert even if up to date
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"


def needs_update(source: Path, target: Path, force: bool) -> bool:
    if force or not target.exists():
        return True
    return source.stat().st_mtime > target.stat().st_mtime


def convert_svg_to_pdf(source: Path, target: Path) -> None:
    rsvg = shutil.which("rsvg-convert")
    if rsvg is None:
        raise SystemExit(
            "rsvg-convert not found. Install librsvg:\n"
            "  brew install librsvg"
        )
    target.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [rsvg, "--format=pdf", "-o", str(target), str(source)],
        check=True,
        cwd=source.parent,
    )


def convert_gif_to_pdf(source: Path, target: Path) -> None:
    # Convert GIF → PNG (temp), then PNG → PDF via sips + preview
    sips = shutil.which("sips")
    if sips is None:
        raise SystemExit("sips not found (expected on macOS).")

    tmp_png = target.with_suffix(".png")
    target.parent.mkdir(parents=True, exist_ok=True)

    # GIF → PNG
    subprocess.run(
        [sips, "-s", "format", "png", str(source), "--out", str(tmp_png)],
        check=True,
        capture_output=True,
    )
    # PNG → PDF
    subprocess.run(
        [sips, "-s", "format", "pdf", str(tmp_png), "--out", str(target)],
        check=True,
        capture_output=True,
    )
    tmp_png.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert SVG/GIF assets to PDF for pdflatex."
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Re-convert all files even if PDF is up to date.",
    )
    args = parser.parse_args()

    converters = {
        ".svg": convert_svg_to_pdf,
        ".gif": convert_gif_to_pdf,
    }

    converted = 0
    for ext, convert_fn in converters.items():
        for source in sorted(ASSETS_DIR.rglob(f"*{ext}")):
            target = source.with_suffix(".pdf")
            if not needs_update(source, target, args.force):
                continue
            convert_fn(source, target)
            rel = target.relative_to(ASSETS_DIR.parent)
            print(f"  {rel}")
            converted += 1

    if converted:
        print(f"Converted {converted} file(s).")
    else:
        print("All assets up to date.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
