#!/usr/bin/env bash
# Companion test — ogni nuovo file sorgente "sostanziale" deve avere un test affiancato.
# Euristico per FastAPI/React. Eccezione: file in shell/, models/, types puri, __init__.py, config.
set -euo pipefail
fail=0
files=(); while IFS= read -r _l; do files+=("$_l"); done < <(git diff --name-only --diff-filter=A origin/main...HEAD 2>/dev/null || true)

is_source() { case "$1" in
  *.test.*|*_test.py|*test_*.py|*.spec.*) return 1;;
  */shell/*|*/models/*|*/__init__.py|*config*|*.d.ts) return 1;;
  *.py|*.ts|*.tsx) return 0;;
  *) return 1;; esac; }

has_companion() {
  local f="$1" base dir stem
  dir=$(dirname "$f"); base=$(basename "$f"); stem="${base%.*}"
  ls "$dir"/test_"$stem".py "$dir"/"$stem"_test.py "$dir"/"$stem".test.* "$dir"/"$stem".spec.* 2>/dev/null | grep -q . && return 0
  # mirror tests/ dir
  git ls-files "tests/**/*$stem*" "**/__tests__/*$stem*" 2>/dev/null | grep -q . && return 0
  return 1
}

for f in ${files[@]+"${files[@]}"}; do
  is_source "$f" || continue
  if ! has_companion "$f"; then
    echo "❌ [test] nuovo sorgente senza test affiancato: $f"; fail=1
  fi
done
[ $fail -eq 0 ] && echo "✅ [test] companion test presenti" || echo "→ Aggiungi un file di test (Step 3 del protocollo). Codice senza test = incompleto."
exit $fail
