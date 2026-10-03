#!/usr/bin/env bash
# Package hallucination — ogni dipendenza NUOVA deve esistere davvero nel registry.
# Controlla solo le righe aggiunte a requirements.txt / pyproject / package.json vs origin/main.
# Best-effort: richiede rete (npm/pip). Salta con SKIP_DEP_CHECK=1.
set -uo pipefail
[ "${SKIP_DEP_CHECK:-0}" = "1" ] && { echo "↷ dep check saltato"; exit 0; }
fail=0

added() { git diff --diff-filter=ACM origin/main...HEAD -- "$1" 2>/dev/null | grep -E '^\+' | grep -v '^\+\+\+' || true; }

# Python
while IFS= read -r line; do
  pkg=$(echo "$line" | sed -E 's/^\+//; s/[<>=!~ ].*//; s/\[.*//; s/[[:space:]]//g')
  [ -z "$pkg" ] && continue; case "$pkg" in \#*|-*) continue;; esac
  if ! pip index versions "$pkg" >/dev/null 2>&1; then
    echo "❌ [pkg] dipendenza Python non trovata sul registry: '$pkg' (hallucination?)"; fail=1
  fi
done < <(added requirements.txt)

# Node
while IFS= read -r line; do
  pkg=$(echo "$line" | grep -oE '"[^"]+"\s*:' | head -1 | sed -E 's/[":]//g; s/[[:space:]]//g')
  [ -z "$pkg" ] && continue; case "$pkg" in dependencies|devDependencies|scripts|name|version) continue;; esac
  if ! npm view "$pkg" version >/dev/null 2>&1; then
    echo "❌ [pkg] dipendenza npm non trovata sul registry: '$pkg' (hallucination?)"; fail=1
  fi
done < <(added package.json)

[ $fail -eq 0 ] && echo "✅ [pkg] dipendenze verificate" || echo "→ Verifica i nomi: l'AI può inventare librerie che attaccanti registrano (supply-chain)."
exit $fail
