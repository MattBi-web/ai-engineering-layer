# AI Engineering Layer

A **personal** extension built on top of [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills)
(installed as a Claude Code plugin: `/spec /plan /build /test /review /ship` cycle, 20+ skills, fan-out
review). **It does not duplicate the process** — this repo adds only the *delta* that agent-skills doesn't cover:

1. **Context Bootstrap on the project's infrastructure** — during `/spec`, it queries the code graph (`codebase-memory` MCP)
   and the Obsidian memory to reuse what already exists → makes DRY actionable and cuts token usage.
2. **Deterministic enforcement** — 3 Non-Negotiables (RLS · rate-limit · secrets) as **pre-commit + CI** gates
   that block the merge. agent-skills is "soft" (skills/personas/prompts); this is "hard".
3. **Default stack** — MVC + FastAPI/React/Supabase stack (an example, customizable) + 12 Production Layers with tiering (rigor ∝ risk).

## Structure
```
AGENTS.md                       # delta (tool-agnostic source of truth); the process is agent-skills
CLAUDE.md                       # Claude Code shim: hooks the delta into the agent-skills cycle
.claude/
  skills/engineering-layers/    # 12 Production Layers with progressive disclosure (loads only the touched layer)
  commands/
    pr-prep.md                  # merge gate (3 NN + layers + template) — review is agent-skills' /review
    audit.md                    # /audit (gaps vs the 12 layers, uses the graph)
.github/PULL_REQUEST_TEMPLATE.md# PR template organized by layer + tier + AI-specific checks
enforcement/                    # 3 lines of defense: pre-commit + Claude hooks + CI (scripts for a FastAPI/Supabase stack)
governance/                     # ADR/runbook/postmortem templates, CODEOWNERS, data-inventory (L11)
distribution/                   # one-liner install.sh + INSTALL.md (distribution package)
WHITEPAPER.md                   # paper: motivation, token ROI, use cases, limitations
```

## Setup (one-liner)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.sh | bash
```
Full setup (agent-skills plugin + codebase-memory MCP + opusplan + rules + templates). Obsidian and a
nightly re-indexing routine are opt-in. See [`distribution/INSTALL.md`](distribution/INSTALL.md)
and the [`WHITEPAPER.md`](WHITEPAPER.md).

## Relationship with agent-skills
| | agent-skills | this extension |
|---|---|---|
| Process (spec→ship), 20+ skills, fan-out review | ✅ | — (uses it) |
| Context Bootstrap on code graph + Obsidian | — | ✅ |
| Deterministic enforcement (pre-commit + CI gate) | — (soft) | ✅ (hard) |
| RLS/rate-limit/secrets Non-Negotiables + Supabase tiering | — | ✅ |

## Status
- ✅ agent-skills installed (`agent-skills@addy-agent-skills`, user scope).
- ✅ Framework refactored into a delta extension (duplicated process prose removed).
- ✅ Enforcement (3 lines of defense) + governance + 12 layers (skill).
- ⏳ Validation: pilot on a real repo to calibrate the heuristic scripts.
- ✅ Distribution: `distribution/install.sh` (one-liner) + `INSTALL.md` + `WHITEPAPER.md` ready.
- ⏳ Publishing: add a `git remote` (GitHub) and push; update `REPO_URL` in `install.sh`.
