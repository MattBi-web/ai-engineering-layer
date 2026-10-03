# L9 — Deployment & Environments

**Scopo:** rilasci sicuri, reversibili e promossi attraverso ambienti, senza downtime sorpresa.

**Decisioni di default:** ambienti dev → staging → prod. Deploy automatico su push (CD). Rollback sempre
disponibile. Feature flag per disaccoppiare deploy da release. Config per-ambiente, mai hardcoded.

**Checklist:**
- [ ] Esiste uno **staging** che rispecchia prod; il cambio passa di lì prima di prod.
- [ ] Strategia di rilascio: canary/blue-green o almeno deploy con health-gate.
- [ ] **Rollback** definito e testato (RTO target dichiarato, coerente con L3 backup).
- [ ] Feature flag per funzionalità rischiose (deploy ≠ release).
- [ ] Config via env per-ambiente; secrets da vault (NN#3); promotion dev→staging→prod tracciata.
- [ ] Migrazioni DB compatibili col deploy (expand-contract, L3) per zero downtime.

**Non-Negotiable:** eredita NN#3 (config/secrets per-ambiente da vault).

**Stop condition:** se manca un ambiente di staging o una via di rollback, fermati e segnalalo prima di
rilasciare codice critico in produzione.
