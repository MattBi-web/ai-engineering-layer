# Enforcement — the 3 lines of defense

The framework's "MUST"s become **executed** constraints, on three levels that reinforce each other.
Target stack: **FastAPI (Python) + React/TS + Supabase**. The scripts are **heuristic** (grep/regex):
great as a safety net, but they need to be calibrated to the real code — they can produce false positives/negatives.
Every script has an **explicit exemption** mechanism (marker comment) for legitimate cases.

## Line 1 — pre-commit (local, before the commit)
```bash
cp enforcement/.pre-commit-config.yaml .pre-commit-config.yaml
pip install pre-commit && pre-commit install
```
Blocks at commit time: missing RLS (NN#1), missing rate limit (NN#2), tracked secrets/.env (NN#3) +
gitleaks, `any` in TS, nonexistent dependencies, source without tests. Can be bypassed with `--no-verify`, but
then Line 3 catches it.

## Line 2 — Claude Code hooks (during development with the agent)
**Merge** `enforcement/claude-settings.hooks.json` into the repo's `.claude/settings.json`
(PROJECT level, not `~/.claude`). It adds:
- **PreToolUse/Bash** → `block-destructive-bash.sh`: blocks `rm -rf`, force pushes, `DROP`, `sudo`, fork bombs.
- **PostToolUse/Edit|Write** → `post-edit-check.sh`: quick lint on the touched file (ruff/eslint), non-blocking.
- **Stop** → `run-tests-on-stop.sh`: runs the test suite; if it fails, **blocks the session from ending** (tests are a constraint).
  Can be disabled with `AENG_SKIP_STOP_TESTS=1` for slow suites.

## Line 3 — CI (at merge, server-side, not bypassable)
- `non-negotiables.yml` — always on: 3 jobs (RLS / rate-limit / secrets+gitleaks). If one fails, no merge.
- `ai-code-gate.yml` — layered: reads the layers checked in the PR body (`detect-layers.sh`) and runs
  only the jobs for the touched layers; if the tier is **critical**, it requires ≥2 approved reviews.

Configure both as **required status checks** on the protected branch in GitHub.

## How it behaves (examples)
- Migration with `CREATE TABLE` without RLS → pre-commit blocks (NN#1); if bypassed, CI blocks the merge.
- Claude tries to finish with failing tests → the Stop hook returns 2, the session doesn't end.
- Cosmetic PR → CI runs the 3 NNs + 1 job. Critical PR → NNs + one job per layer + 2-review gate.

## Calibrating to your stack
- `check-rate-limit.sh`: adapt the patterns to your limiter (currently looks for slowapi/limiter/RateLimit).
- `check-test-present.sh`: adapt to your test naming/location conventions.
- `check-rls.sh`: if you use app-level authz instead of Postgres RLS, replace the check.
