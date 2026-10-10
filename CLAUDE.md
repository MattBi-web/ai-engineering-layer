# CLAUDE.md — Claude Code shim

Claude Code does not read `AGENTS.md` natively: this shim is load-bearing.
**Read and apply [AGENTS.md](./AGENTS.md).** This file contains only the Claude Code-specific wiring.

## Process = agent-skills (installed)
The development cycle (spec/plan/build/test/review/ship + 20+ skills + fan-out review) is provided by the
`agent-skills@addy-agent-skills` plugin. **Do not reinvent it.** This repo adds only the delta.

## Hooking the delta into the agent-skills cycle
- **In `/spec` (DEFINE)** → run the **Context Bootstrap** (AGENTS.md §A): query `codebase-memory`
  (`get_architecture`/`search_graph`/`search_code`/`trace_path`) and `obsidian` (`search-vault`) to reuse
  what exists, before proposing the architecture.
- **In `/ship` (SHIP)** → run the **3 Non-Negotiables** (RLS / rate-limit / secrets) via `enforcement/`;
  if one fails, NO-GO. The actual code review is done by agent-skills' `/review` (fan-out); do not duplicate it.
- For every change, declare the **layers** touched and load the checklist from the `engineering-layers` skill.

## Model routing (cost discipline)
Default `opusplan`. When delegating via **Agent**: `opus` for spec/review, `sonnet` for test/impl, `haiku` for Context Bootstrap lookups.

## Progressive disclosure
Do not inline the 12 layers: load only the touched one from the `engineering-layers` skill. Keep this file and AGENTS.md lean.
