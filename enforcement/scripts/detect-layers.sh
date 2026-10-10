#!/usr/bin/env bash
# PR body parser: extracts the ticked layers (L0..L11) and the declared tier.
# Usage: detect-layers.sh < pr_body.md   (or pass the path as $1)
# Output: lines "layer=Lx" and "tier=<cosmetic|standard|critical>" (for conditional CI jobs).
set -euo pipefail
body=$(cat "${1:-/dev/stdin}")

# ticked layers: lines "- [x] **Lx ...**"
echo "$body" | grep -ioE '^\s*-\s*\[x\]\s*\*\*L[0-9]+' | grep -ioE 'L[0-9]+' | sort -u | sed 's/^/layer=/'

# tier
for t in critical standard cosmetic; do
  if echo "$body" | grep -iqE "^\s*-\s*\[x\]\s*\*\*$t"; then echo "tier=$t"; break; fi
done
