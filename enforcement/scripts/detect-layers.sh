#!/usr/bin/env bash
# Parser del corpo PR: estrae i layer spuntati (L0..L11) e il tier dichiarato.
# Uso: detect-layers.sh < pr_body.md   (oppure passa il path come $1)
# Output: righe "layer=Lx" e "tier=<cosmetic|standard|critical>" (per i job condizionali in CI).
set -euo pipefail
body=$(cat "${1:-/dev/stdin}")

# layer spuntati: righe "- [x] **Lx ...**"
echo "$body" | grep -ioE '^\s*-\s*\[x\]\s*\*\*L[0-9]+' | grep -ioE 'L[0-9]+' | sort -u | sed 's/^/layer=/'

# tier
for t in critical standard cosmetic; do
  if echo "$body" | grep -iqE "^\s*-\s*\[x\]\s*\*\*$t"; then echo "tier=$t"; break; fi
done
