#!/usr/bin/env bash
# Claude Code hook (Stop). Esegue la test-suite del progetto; se fallisce, blocca la chiusura (exit 2)
# così il "MUST" sui test è un vincolo, non un'opinione. Salta con AENG_SKIP_STOP_TESTS=1.
# Nota: pensato per progetti dove i test sono veloci; per suite lente, scopalo o usalo solo in CI.
set -uo pipefail
[ "${AENG_SKIP_STOP_TESTS:-0}" = "1" ] && exit 0

run() { echo "▶ [stop-hook] $*" >&2; "$@" >&2; }

if [ -f pytest.ini ] || grep -qs 'pytest' pyproject.toml 2>/dev/null; then
  if command -v pytest >/dev/null 2>&1; then
    run pytest -q || { echo "⛔ [stop-hook] test Python falliti — non chiudo finché non passano." >&2; exit 2; }
  fi
elif [ -f package.json ] && grep -q '"test"' package.json; then
  if command -v npm >/dev/null 2>&1; then
    run npm test --silent || { echo "⛔ [stop-hook] test JS/TS falliti — non chiudo finché non passano." >&2; exit 2; }
  fi
fi
exit 0
