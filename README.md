# AI Engineering Layer

Estensione **personale** che poggia su [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills)
(installato come plugin Claude Code: ciclo `/spec /plan /build /test /review /ship`, 23 skill, review in
fan-out). **Non duplichiamo il processo** — questo repo aggiunge solo il *delta* che agent-skills non copre:

1. **Context Bootstrap sull'infrastruttura del progetto** — durante `/spec`, interroga il code-graph (`codebase-memory` MCP)
   e la memoria Obsidian per riusare l'esistente → rende eseguibile il DRY e abbatte i token.
2. **Enforcement deterministico** — 3 Non-Negotiables (RLS · rate-limit · secrets) come gate **pre-commit + CI**
   che bloccano il merge. agent-skills è "soft" (skill/persona/prompt); questo è "hard".
3. **Default stack** — MVC + stack FastAPI/React/Supabase (esempio, personalizzabile) + 12 Production Layers con tiering (rigore ∝ rischio).

## Struttura
```
AGENTS.md                       # delta (fonte di verità tool-agnostic); il processo è agent-skills
CLAUDE.md                       # shim Claude Code: aggancia il delta al ciclo agent-skills
.claude/
  skills/engineering-layers/    # 12 Production Layers a progressive disclosure (carica solo il layer toccato)
  commands/
    pr-prep.md                  # gate org (3 NN + layer + template) — la review è /review di agent-skills
    audit.md                    # /audit (gap vs 12 layer, usa il grafo)
.github/PULL_REQUEST_TEMPLATE.md# PR template stratificato per layer + tier + check AI-specifici
enforcement/                    # 3 cordoni: pre-commit + Claude hooks + CI (script su stack FastAPI/Supabase)
governance/                     # template ADR/runbook/postmortem, CODEOWNERS, data-inventory (L11)
distribution/                   # one-liner install.sh + INSTALL.md (pacchetto di distribuzione)
WHITEPAPER.md                   # paper: motivazione, ROI sui token, casi d'uso, limiti
```

## Setup (one-liner)
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/main/distribution/install.sh | bash
```
Setup completo (plugin agent-skills + MCP codebase-memory + opusplan + regole + template). Opt-in
Obsidian e routine notturna di re-indexing. Vedi [`distribution/INSTALL.md`](distribution/INSTALL.md)
e il [`WHITEPAPER.md`](WHITEPAPER.md).

## Relazione con agent-skills
| | agent-skills | questa estensione |
|---|---|---|
| Processo (spec→ship), 23 skill, review fan-out | ✅ | — (lo usa) |
| Context Bootstrap su code-graph + Obsidian | — | ✅ |
| Enforcement deterministico (pre-commit + CI gate) | — (soft) | ✅ (hard) |
| Non-Negotiables RLS/rate-limit/secrets + tiering Supabase | — | ✅ |

## Stato
- ✅ agent-skills installato (`agent-skills@addy-agent-skills`, scope user).
- ✅ Framework rifattorizzato in estensione-delta (rimossa la prosa di processo duplicata).
- ✅ Enforcement (3 cordoni) + governance + 12 layer (skill).
- ⏳ Validazione: pilota su un repo reale per tarare gli script euristici.
- ✅ Distribuzione: `distribution/install.sh` (one-liner) + `INSTALL.md` + `WHITEPAPER.md` pronti.
- ⏳ Pubblicazione: aggiungere `git remote` (GitHub) e pushare; aggiornare `REPO_URL` in `install.sh`.
