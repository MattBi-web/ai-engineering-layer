#!/usr/bin/env bash
# NN#3 — nessun file di secrets versionato + nessun secret in chiaro evidente.
# (gitleaks fa lo scan profondo; questo è il guardrail veloce.)
set -euo pipefail
fail=0

# 1) nessun .env tracciato (eccetto esempi)
tracked_env=$(git ls-files | grep -E '(^|/)\.env($|\.)' | grep -vE '\.env\.(example|sample|template)$' || true)
if [ -n "$tracked_env" ]; then
  echo "❌ [NN#3] file .env tracciati da git:"; echo "$tracked_env" | sed 's/^/    /'; fail=1
fi

# 2) pattern di secret evidenti nei file modificati
files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  files=(); while IFS= read -r _l; do files+=("$_l"); done < <(git diff --name-only --diff-filter=ACM origin/main...HEAD 2>/dev/null || true)
fi
pat='(sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,})'
for f in ${files[@]+"${files[@]}"}; do
  [ -f "$f" ] || continue
  case "$f" in *.example|*.sample|*.template) continue;; esac
  if grep -nEq "$pat" "$f"; then
    echo "❌ [NN#3] possibile secret in chiaro in $f"; grep -nE "$pat" "$f" | sed 's/^/    /'; fail=1
  fi
done

[ $fail -eq 0 ] && echo "✅ [NN#3] secrets ok" || echo "→ Sposta i secrets in vault/KMS/env-a-runtime; aggiungi .env a .gitignore."
exit $fail
