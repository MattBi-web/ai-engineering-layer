# L4 — Auth (Authentication & Authorization)

**Scopo:** sai CHI è l'utente (authn) e COSA può fare (authz), separati e applicati a ogni richiesta.

**Decisioni di default:** Supabase Auth per authn. Authz applicata sia a livello DB (RLS, vedi L3) sia
a livello service. Sessioni con access token a vita breve + refresh token. Mai authz solo lato frontend.

**Checklist:**
- [ ] **Authentication ≠ Authorization**: separate. L'identità non implica il permesso.
- [ ] Ogni endpoint/risorsa verifica i permessi lato server (mai fidarsi del client).
- [ ] RLS allineata ai ruoli (coerenza con L3): la policy DB rispecchia l'authz applicativa.
- [ ] Access token a vita breve + refresh token con rotazione/revoca; logout invalida la sessione.
- [ ] Nessun controllo di autorizzazione solo nella UI (le `pages/` non sono una barriera di sicurezza).
- [ ] Path critici (auth/payment) → tier critical (L0), review umana obbligatoria.

**Non-Negotiable:** abilita NN#1 (l'authz a livello dati è la RLS).

**Stop condition:** se il modello di ruoli/permessi non è definito, fermati e chiedi; non inventare uno schema di autorizzazione.
