---
description: Audit on-demand del repo contro il framework — misura il gap rispetto ai 12 layer e alle 3 NN
argument-hint: (opzionale) ambito, es. "ultimo mese" o un percorso
---

Esegui un audit di ingegneria del repo corrente contro il framework AI Engineering Layer. Ambito: **${ARGUMENTS:-intero repo}**.

### 1. Stato del codice (usa il grafo se il progetto è indicizzato)
`codebase-memory` MCP: `get_architecture` + `search_graph` per route/tabelle/servizi. Altrimenti `git ls-files`.

### 2. 3 Non-Negotiables (sull'intero repo, non solo sul diff)
Esegui (o simula con grep) gli script di `enforcement/scripts/`:
- RLS su ogni tabella (`check-rls.sh` su tutte le migration)
- rate limit su ogni endpoint pubblico (`check-rate-limit.sh`)
- nessun secret tracciato (`check-env-tracked.sh` + presenza di `.env` in `.gitignore`)

### 3. Copertura dei 12 layer
Per ogni layer L0–L11, valuta: è presente nel progetto? con che maturità? Produci una tabella
`Layer | stato (✅/🟡/❌) | gap`. Usa la skill `engineering-layers` come riferimento dei criteri.

### 4. Governance
Esistono: `CODEOWNERS`, ADR per le decisioni non banali, runbook per i servizi in prod, `data-inventory`
per il PII? Segnala i mancanti.

### 5. Report
Sintesi finale: punteggio qualitativo per layer, top 5 gap per impatto, e 3 azioni concrete prioritarie.
Se il progetto è critico (auth/payment/PII), evidenzia i rischi di sicurezza per primi.
