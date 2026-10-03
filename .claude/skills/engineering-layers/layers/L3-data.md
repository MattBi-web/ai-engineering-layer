# L3 — Data

**Scopo:** schema dati corretto, sicuro e migrabile senza downtime; nessuna tabella esposta "aperta".

**Decisioni di default:** Postgres/Supabase. Ogni tabella nasce con RLS abilitata. Migrazioni
versionate in `migrations/`, pattern expand-contract. Backup con RPO/RTO dichiarati.

**Checklist:**
- [ ] **NN#1**: ogni `CREATE TABLE` con dati non pubblici ha `ENABLE ROW LEVEL SECURITY` + almeno una `CREATE POLICY` nella STESSA migration.
- [ ] Migrazione zero-downtime: nessuna colonna NOT NULL senza default su tabella popolata; pattern expand→migrate→contract per rename/drop.
- [ ] Indici sulle colonne usate da query/policy; foreign key esplicite.
- [ ] Nessun dato sensibile in chiaro (vedi L5/L11); colonne PII marcate nel data-inventory.
- [ ] Strategia di backup e restore *testata* (non solo configurata); RPO/RTO annotati.
- [ ] Rollback della migration definito.

**Repo senza migration SQL (Supabase client/ORM):** la RLS vive su Supabase e non è verificabile dal codice
→ serve un'**attestazione tracciata** in `governance/rls-attestation.md` (o "RLS: enabled" per tabella in
`data-inventory.md`). Il check `check-rls.sh` la richiede in questo caso.

**Non-Negotiable:** NN#1 — RLS/authz su ogni tabella non pubblica.

**Stop condition:** se una tabella deve restare senza RLS (es. dati pubblici), fermati e crea un ADR
che documenti l'eccezione; non disabilitare RLS silenziosamente.
