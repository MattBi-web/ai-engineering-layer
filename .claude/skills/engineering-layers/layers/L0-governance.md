# L0 — Governance (cross-cutting)

**Scopo:** ogni cambiamento ha un proprietario, una motivazione tracciata e un livello di rigore proporzionato.

**Decisioni di default:** ownership via `CODEOWNERS`. Decisioni architetturali in ADR. Glossario di
dominio condiviso. Ogni PR dichiara un **tier**.

**Tier (il rigore scala col rischio):**
- **cosmetic** — UI/copy/stile: flusso standard, review leggera.
- **standard** — feature/bugfix normali: protocollo a 5 step completo.
- **critical** — auth, payment, PII, migrazioni: review umana obbligatoria (≥2 approvazioni) + security scan.

**Checklist:**
- [ ] Tier dichiarato nella PR; se critical, reviewer umano assegnato.
- [ ] Path coperto da `CODEOWNERS`.
- [ ] Decisione non banale → ADR creato/aggiornato (`governance/ADR/`).
- [ ] Termini di dominio nuovi → glossario aggiornato.

**Non-Negotiable:** nessuna.

**Stop condition:** se non è chiaro il tier o manca un owner per il path toccato, fermati e chiedi.
