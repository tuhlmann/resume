#!/usr/bin/env bash
#
# optimize_images.sh — One-time image optimization for resume assets.
#
# Downsizes raster images to appropriate dimensions for their rendered
# size in the LaTeX resume (logos: 0.9 cm ≈ 128 px at 300 DPI,
# portrait: 2.8 cm ≈ 330 px at 300 DPI).
#
# Uses macOS `sips` — no extra dependencies required.
# Run manually whenever source images change:
#
#   bash scripts/optimize_images.sh
#

set -euo pipefail

ASSETS_DIR="$(cd "$(dirname "$0")/../assets" && pwd)"

# Max dimension (longest side) for each category
LOGO_MAX=128
PORTRAIT_MAX=330

optimize_image() {
  local file="$1"
  local max_dim="$2"

  if [[ ! -f "$file" ]]; then
    echo "  SKIP (not found): $file"
    return
  fi

  local w h
  w=$(sips -g pixelWidth "$file" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$file" 2>/dev/null | awk '/pixelHeight/{print $2}')

  if [[ -z "$w" || -z "$h" ]]; then
    echo "  SKIP (cannot read dimensions): $file"
    return
  fi

  # Determine the longest side
  local longest=$w
  if (( h > w )); then
    longest=$h
  fi

  if (( longest <= max_dim )); then
    echo "  OK   $(basename "$file") — already ${w}x${h} (max ${max_dim})"
    return
  fi

  local before
  before=$(stat -f%z "$file")

  # sips --resampleHeightWidthMax scales the longest side to the given value
  sips --resampleHeightWidthMax "$max_dim" "$file" >/dev/null 2>&1

  local after
  after=$(stat -f%z "$file")
  local new_w new_h
  new_w=$(sips -g pixelWidth "$file" 2>/dev/null | awk '/pixelWidth/{print $2}')
  new_h=$(sips -g pixelHeight "$file" 2>/dev/null | awk '/pixelHeight/{print $2}')

  echo "  DONE $(basename "$file") — ${w}x${h} → ${new_w}x${new_h}  (${before} → ${after} bytes)"
}

echo "=== Optimizing portrait ==="
optimize_image "$ASSETS_DIR/torsten_square.jpg" "$PORTRAIT_MAX"

echo ""
echo "=== Optimizing client logos ==="
for f in "$ASSETS_DIR"/clients/*.png "$ASSETS_DIR"/clients/*.gif "$ASSETS_DIR"/clients/*.jpg; do
  [[ -f "$f" ]] && optimize_image "$f" "$LOGO_MAX"
done

echo ""
echo "=== Optimizing product images ==="
for f in "$ASSETS_DIR"/products/*.png "$ASSETS_DIR"/products/*.jpg; do
  [[ -f "$f" ]] && optimize_image "$f" "$LOGO_MAX"
done

echo ""
echo "=== Vector PDFs (no changes needed) ==="
for f in "$ASSETS_DIR"/clients/*.pdf "$ASSETS_DIR"/products/*.pdf; do
  [[ -f "$f" ]] && echo "  KEEP $(basename "$f") — $(stat -f%z "$f") bytes"
done

echo ""
echo "=== Summary ==="
total_before=0
total_after=0
for f in $(find "$ASSETS_DIR" -maxdepth 2 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.gif' \)); do
  total_after=$((total_after + $(stat -f%z "$f")))
done
echo "Total raster size after optimization: ${total_after} bytes ($((total_after / 1024)) KB)"
echo "Done. Rebuild with: make pdf"
