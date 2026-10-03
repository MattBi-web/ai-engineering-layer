# Enforcement — i 3 cordoni

I "MUST" del framework diventano vincoli **eseguiti**, su tre livelli che si rinforzano a vicenda.
Stack target: **FastAPI (Python) + React/TS + Supabase**. Gli script sono **euristici** (grep/regex):
ottimi come rete di sicurezza, ma vanno tarati sul codice reale — possono dare falsi positivi/negativi.
Ogni script ha un meccanismo di **esenzione esplicita** (commento marker) per i casi legittimi.

## Cordone 1 — pre-commit (locale, prima del commit)
```bash
cp enforcement/.pre-commit-config.yaml .pre-commit-config.yaml
pip install pre-commit && pre-commit install
```
Blocca al commit: RLS mancante (NN#1), rate-limit mancante (NN#2), secrets/.env tracciati (NN#3) +
gitleaks, `any` in TS, dipendenze inesistenti, sorgente senza test. Aggirabile con `--no-verify`, ma
poi lo prende il Cordone 3.

## Cordone 2 — Claude Code hooks (durante lo sviluppo con l'agente)
Fai il **merge** di `enforcement/claude-settings.hooks.json` dentro il `.claude/settings.json` del repo
(livello PROGETTO, non `~/.claude`). Aggiunge:
- **PreToolUse/Bash** → `block-destructive-bash.sh`: blocca `rm -rf`, push forzati, `DROP`, `sudo`, fork bomb.
- **PostToolUse/Edit|Write** → `post-edit-check.sh`: lint rapido sul file toccato (ruff/eslint), non bloccante.
- **Stop** → `run-tests-on-stop.sh`: esegue la test-suite; se rossa, **blocca la chiusura** (i test sono un vincolo).
  Disattivabile con `AENG_SKIP_STOP_TESTS=1` per suite lente.

## Cordone 3 — CI (al merge, lato server, non aggirabile)
- `non-negotiables.yml` — sempre attivo: 3 job (RLS / rate-limit / secrets+gitleaks). Se uno fallisce, niente merge.
- `ai-code-gate.yml` — stratificato: legge i layer spuntati nel corpo della PR (`detect-layers.sh`) e attiva
  solo i job dei layer toccati; se il tier è **critical**, richiede ≥2 review approvate.

Configura i due come **required status checks** sul branch protetto in GitHub.

## Come si comporta (esempi)
- Migration con `CREATE TABLE` senza RLS → pre-commit blocca (NN#1); se aggiri, la CI blocca il merge.
- Claude prova a chiudere con test rossi → hook Stop ritorna 2, la sessione non si chiude.
- PR cosmetic → CI gira 3 NN + 1 job. PR critical → NN + job per ogni layer + gate 2-review.

## Tarare sul tuo stack
- `check-rate-limit.sh`: adatta i pattern del tuo limiter (ora cerca slowapi/limiter/RateLimit).
- `check-test-present.sh`: adatta le convenzioni di naming/posizione dei test.
- `check-rls.sh`: se usi authz a livello app invece di RLS Postgres, sostituisci il check.
