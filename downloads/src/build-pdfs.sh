#!/usr/bin/env bash
# Generate ATS-friendly, text-based PDFs from canonical Markdown sources, in EN/SR/RU.
# Pipeline: pandoc (md -> html fragment) -> wrap with ATS template (lang set) -> weasyprint.
#
# Sources (canonical EN + translated variants produced by the HelixTranslate pipeline):
#   cv.md  cv.sr.md  cv.ru.md
#   cover-letter.md  cover-letter.sr.md  cover-letter.ru.md
# Missing language sources are skipped with a warning (never fail the whole build).
set -euo pipefail
cd "$(dirname "$0")"
OUT=".."   # downloads/

build() {
  local md="$1" out="$2" title="$3" lang="$4"
  [ -f "$md" ] || { echo "  -- skip ${out} (no source ${md})"; return 0; }
  pandoc "$md" -f markdown -t html5 -o "/tmp/${out}.frag.html"
  cat > "/tmp/${out}.html" <<HTML
<!DOCTYPE html><html lang="${lang}"><head><meta charset="utf-8">
<title>${title}</title><link rel="stylesheet" href="ats.css"></head>
<body>
$(cat "/tmp/${out}.frag.html")
</body></html>
HTML
  weasyprint "/tmp/${out}.html" "${OUT}/${out}.pdf" -u . >/dev/null 2>&1
  echo "  -> ${OUT}/${out}.pdf ($(du -h "${OUT}/${out}.pdf" | cut -f1))"
}

# doc-base : output-base : title
docs=(
  "cv:Milos_Vasic_CV:Milos Vasic — CV"
  "cover-letter:Milos_Vasic_Cover_Letter:Milos Vasic — Cover Letter"
)

echo "Building localized PDFs (EN/SR/RU):"
for spec in "${docs[@]}"; do
  IFS=":" read -r base outbase title <<<"$spec"
  # EN (canonical source <base>.md) -> _EN.pdf AND legacy <outbase>.pdf
  build "${base}.md"    "${outbase}_EN" "${title} (EN)" "en"
  build "${base}.md"    "${outbase}"    "${title}"      "en"
  # SR / RU translated sources
  build "${base}.sr.md" "${outbase}_SR" "${title} (SR)" "sr"
  build "${base}.ru.md" "${outbase}_RU" "${title} (RU)" "ru"
done
echo "Done."
