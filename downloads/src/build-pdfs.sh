#!/usr/bin/env bash
# Generate ATS-friendly, text-based PDFs from the canonical Markdown sources.
# Pipeline: pandoc (md -> html fragment) -> wrap with ATS template -> weasyprint (html -> pdf)
set -euo pipefail
cd "$(dirname "$0")"
OUT=".."   # downloads/

build() {
  local md="$1" out="$2" title="$3"
  pandoc "$md" -f markdown -t html5 -o "/tmp/${out}.frag.html"
  cat > "/tmp/${out}.html" <<HTML
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<title>${title}</title><link rel="stylesheet" href="ats.css"></head>
<body>
$(cat "/tmp/${out}.frag.html")
</body></html>
HTML
  weasyprint "/tmp/${out}.html" "${OUT}/${out}.pdf" -u . >/dev/null 2>&1
  echo "  -> ${OUT}/${out}.pdf ($(du -h "${OUT}/${out}.pdf" | cut -f1))"
}

echo "Building PDFs:"
build cv.md            "Milos_Vasic_CV"           "Milos Vasic — CV"
build cover-letter.md  "Milos_Vasic_Cover_Letter" "Milos Vasic — Cover Letter"
echo "Done."
