#!/usr/bin/env bash
# NN#2 — rate limiting EFFETTIVO sugli endpoint pubblici (FastAPI). Euristico, portabile (bash 3.2+).
# Logica per-file:
#   1) se c'è un rate-limit GLOBALE (middleware/limiter di app) → tutte le route coperte → PASS (con nota);
#   2) altrimenti PER-ROUTE: conta le route e quelle con limiter esplicito; se restano route scoperte → fail.
# Eccezione per-file: commento "# rate-limit-exempt: <motivo>" (es. router interno/health).
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
    echo "✅ [NN#2] $f: rate-limit globale rilevato → $routes route coperte dal middleware/limiter"
    continue
  fi
  limited=$(grep -cE "$PERROUTE_PAT" "$f" 2>/dev/null || true); limited=${limited:-0}
  if [ "$limited" -lt "$routes" ]; then
    echo "❌ [NN#2] $f: $routes route, solo $limited con rate-limit esplicito e nessun middleware globale → endpoint scoperti"
    fail=1
  else
    echo "✅ [NN#2] $f: $routes route, $limited con rate-limit per-route"
  fi
done

[ $fail -eq 0 ] && echo "✅ [NN#2] rate limit ok" || echo "→ Aggiungi un middleware globale (es. slowapi) o un limiter per-route, oppure '# rate-limit-exempt: <motivo>' per i router interni."
exit $fail
