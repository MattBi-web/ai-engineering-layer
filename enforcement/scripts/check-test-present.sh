#!/usr/bin/env bash
# Companion test — every new "substantial" source file must have a test alongside it.
# Heuristic for FastAPI/React. Exempt: files in shell/, models/, pure types, __init__.py, config.
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
    echo "❌ [test] new source file without a companion test: $f"; fail=1
  fi
done
[ $fail -eq 0 ] && echo "✅ [test] companion tests present" || echo "→ Add a test file (Step 3 of the protocol). Code without tests = incomplete."
exit $fail
