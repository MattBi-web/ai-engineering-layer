#!/usr/bin/env bash
# Claude Code hook (Stop). Runs the project's test suite; if it fails, blocks the stop (exit 2)
# so the "MUST" on tests is a constraint, not an opinion. Skip with AENG_SKIP_STOP_TESTS=1.
# Note: meant for projects with fast tests; for slow suites, narrow its scope or use it only in CI.
set -uo pipefail
[ "${AENG_SKIP_STOP_TESTS:-0}" = "1" ] && exit 0

run() { echo "▶ [stop-hook] $*" >&2; "$@" >&2; }

if [ -f pytest.ini ] || grep -qs 'pytest' pyproject.toml 2>/dev/null; then
  if command -v pytest >/dev/null 2>&1; then
    run pytest -q || { echo "⛔ [stop-hook] Python tests failed — not stopping until they pass." >&2; exit 2; }
  fi
elif [ -f package.json ] && grep -q '"test"' package.json; then
  if command -v npm >/dev/null 2>&1; then
    run npm test --silent || { echo "⛔ [stop-hook] JS/TS tests failed — not stopping until they pass." >&2; exit 2; }
  fi
fi
exit 0
