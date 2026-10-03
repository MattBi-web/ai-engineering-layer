# CLAUDE.md — shim per Claude Code

Claude Code non legge `AGENTS.md` nativamente: questo shim è load-bearing.
**Leggi e applica [AGENTS.md](./AGENTS.md).** Qui solo il wiring Claude-Code-specifico.

## Processo = agent-skills (installato)
Il ciclo di sviluppo (spec/plan/build/test/review/ship + 23 skill + review in fan-out) è fornito dal
plugin `agent-skills@addy-agent-skills`. **Non reinventarlo.** Questo repo aggiunge solo il delta.

## Aggancio del delta al ciclo di agent-skills
- **In `/spec` (DEFINE)** → esegui il **Context Bootstrap** (AGENTS.md §A): interroga `codebase-memory`
  (`get_architecture`/`search_graph`/`search_code`/`trace_path`) e `obsidian` (`search-vault`) per riusare
  l'esistente, prima di proporre l'architettura.
- **In `/ship` (SHIP)** → esegui le **3 Non-Negotiables** (RLS / rate-limit / secrets) via `enforcement/`;
  se una fallisce, NO-GO. La code-review vera la fa `/review` di agent-skills (fan-out), non duplicarla.
- Per ogni cambiamento, dichiara i **layer** toccati e carica la checklist dalla skill `engineering-layers`.

## Model routing (cost discipline)
Default `opusplan`. Delegando via **Agent**: `opus` per spec/review, `sonnet` per test/impl, `haiku` per i lookup del Context Bootstrap.

## Progressive disclosure
Non inlineare i 12 layer: carica solo quello toccato dalla skill `engineering-layers`. Tieni questo file e AGENTS.md snelli.
