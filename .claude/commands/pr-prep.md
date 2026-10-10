---
description: Prepara la PR — esegue le 3 Non-Negotiables, la checklist per-layer, e compila il PR template
argument-hint: (opzionale) target branch, default main
---

Prepara la Pull Request per le modifiche correnti. Target: **${ARGUMENTS:-main}**.

> Questo è il **gate di merge** (3 Non-Negotiables + dichiarazione layer + compilazione template), NON la code
> review: per la review usa `/review` di agent-skills (fan-out code-reviewer/security-auditor/test-engineer).

### 1. Raccogli il diff
`git diff --stat ${ARGUMENTS:-main}...HEAD` e `git diff ${ARGUMENTS:-main}...HEAD` per vedere cosa cambia.

### 2. 3 Non-Negotiables (PRIMA di tutto — se una fallisce: NO-GO immediato)
- **NN#1 RLS**: ogni nuova/modificata tabella ha `ENABLE ROW LEVEL SECURITY` + `CREATE POLICY` nella stessa migration.
- **NN#2 Rate limit**: ogni nuovo endpoint pubblico ha rate limiting.
- **NN#3 Secrets**: nessun secret in file tracciati; `.env` ignorato; nessuna API key in chiaro.
(Se nel repo ci sono `enforcement/scripts/`, eseguili; altrimenti verifica manualmente sul diff.)

### 3. Rileva i layer toccati e applica le checklist
Dal diff, deduci quali layer L0–L11 sono coinvolti. Per CIASCUNO, carica la scheda dalla skill
`engineering-layers` e verifica la checklist contro il diff. Elenca i punti soddisfatti e quelli mancanti.

### 4. Tier
Classifica la PR: **cosmetic** / **standard** / **critical** (auth, payment, PII, migrazioni → critical
= richiede ≥2 review umane + security scan).

### 5. Self-review → poi reviewer separato
Genera il **compliance report**: cosa è stato fatto, cosa NON è stato fatto, dove sono state fatte
assunzioni. Per PR `standard`/`critical`, raccomanda di lanciare lo Step 5 con un subagent `opus` separato.

### 6. Compila il PR template
Riempi `.github/PULL_REQUEST_TEMPLATE.md`: spunta solo i layer toccati, compila le loro sezioni, le 3 NN,
i check AI-specifici e le note architetturali. Restituisci il markdown pronto da incollare.
