#!/usr/bin/env bash
# NN#2 — EFFECTIVE rate limiting on public endpoints (FastAPI). Heuristic, portable (bash 3.2+).
# Per-file logic:
#   1) if there is a GLOBAL rate limit (app-level middleware/limiter) → all routes covered → PASS (with a note);
#   2) otherwise PER-ROUTE: count routes and those with an explicit limiter; if any route is uncovered → fail.
# Per-file exemption: comment "# rate-limit-exempt: <reason>" (e.g. internal/health router).
set -euo pipefail
fail=0

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  files=(); while IFS= read -r _l; do files+=("$_l"); done < <(git diff --name-only --diff-filter=ACM origin/main...HEAD 2>/dev/null | grep -E '\.py$' || true)
fi

GLOBAL_PAT='add_middleware\([^)]*(SlowAPI|RateLimit)|RateLimitMiddleware|app\.state\.limiter|FastAPILimiter\.init|Limiter\('
ROUTE_PAT='@(app|router)\.(get|post|put|patch|delete)\('
PERROUTE_PAT='@limiter\.limit|Depends\(\s*RateLimiter|dependencies=\[[^]]*[Rr]ate|@throttle'

for f in ${files[@]+"${files[@]}"}; do
  [ -f "$f" ] || continue
  grep -qE '#\s*rate-limit-exempt' "$f" && continue
  routes=$(grep -cE "$ROUTE_PAT" "$f" 2>/dev/null || true); routes=${routes:-0}
  [ "$routes" -eq 0 ] && continue
  if grep -qE "$GLOBAL_PAT" "$f"; then
    echo "✅ [NN#2] $f: global rate limit detected → $routes routes covered by middleware/limiter"
    continue
  fi
  limited=$(grep -cE "$PERROUTE_PAT" "$f" 2>/dev/null || true); limited=${limited:-0}
  if [ "$limited" -lt "$routes" ]; then
    echo "❌ [NN#2] $f: $routes routes, only $limited with explicit rate limit and no global middleware → uncovered endpoints"
    fail=1
  else
    echo "✅ [NN#2] $f: $routes routes, $limited with per-route rate limit"
  fi
done

[ $fail -eq 0 ] && echo "✅ [NN#2] rate limit ok" || echo "→ Add a global middleware (e.g. slowapi) or a per-route limiter, or '# rate-limit-exempt: <reason>' for internal routers."
exit $fail
