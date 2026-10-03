# L1 — Architecture

**Scopo:** struttura MVC pulita, single-responsibility, zero duplicazione.

**Decisioni di default:** MVC "ristorante" (AGENTS.md §2). Split `backend/`+`frontend/`. Feature = nuovo
modulo (controller+service) + page+service frontend. Codice condiviso in `shared/`.

**Checklist:**
- [ ] Context Bootstrap eseguito: cercato nel grafo/Obsidian un componente esistente da riusare (DRY).
- [ ] Controller = solo routing, nessuna logica di business. Service = logica + unico accesso DB.
- [ ] Pages = solo UI; chiamate al backend solo via frontend `services/` (mai HTTP diretto da una page).
- [ ] Nuova feature = nuovo modulo, non "bolt-on" su moduli esistenti.
- [ ] Test single-responsibility: cambiare UI tocca solo `pages/`; cambiare DB solo i service.
- [ ] Se il cambio forza edit su layer non correlati → struttura sbagliata, refactor prima di procedere.
- [ ] Se il dominio NON è transazionale (ML/event-driven/static) → proposta alternativa, non MVC forzato.

**Non-Negotiable:** nessuna (ma abilita la DRY mandate via Context Bootstrap).

**Stop condition:** se l'architettura corretta non è MVC o non è chiara dal dominio, fermati e proponi.
