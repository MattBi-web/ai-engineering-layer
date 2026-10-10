#!/usr/bin/env bash
# Type safety — forbids `any` in TypeScript in modified files. Exemption: comment "// any-ok: <reason>".
set -euo pipefail
fail=0
files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  files=(); while IFS= read -r _l; do files+=("$_l"); done < <(git diff --name-only --diff-filter=ACM origin/main...HEAD 2>/dev/null | grep -E '\.tsx?$' || true)
fi
for f in ${files[@]+"${files[@]}"}; do
  [ -f "$f" ] || continue
  while IFS=: read -r ln content; do
    echo "$content" | grep -qE '//\s*any-ok' && continue
    echo "❌ [type] $f:$ln  use of 'any' → $content"; fail=1
  done < <(grep -nE '(:\s*any\b|<any>|as any\b|Array<any>|: any\[)' "$f" || true)
done
[ $fail -eq 0 ] && echo "✅ [type] no 'any'" || echo "→ Define an explicit type/interface, or use '// any-ok: <reason>' if unavoidable."
exit $fail
