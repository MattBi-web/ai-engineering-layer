# L11 — Compliance & Data Governance (condizionale)

**Scopo:** i dati personali/regolati sono trattati legalmente, tracciati e cancellabili. Si attiva SOLO
se la PR tocca PII o dati regolati.

**Decisioni di default:** ogni dato PII è censito nel `governance/data-inventory.md`. Retention applicata
e documentata. Audit trail sugli accessi sensibili. GDPR/HIPAA dove applicabile.

**Checklist:**
- [ ] Ogni campo PII nuovo/modificato è registrato in `data-inventory.md` (classificazione, base giuridica, retention).
- [ ] PII protetta: RLS (NN#1) + encryption in transit/at rest (L5); nessun PII nei log (L5/L8).
- [ ] Retention: meccanismo di cancellazione/anonimizzazione previsto e documentato.
- [ ] Audit trail per accessi a dati sensibili (chi/quando/perché).
- [ ] Diritti dell'interessato (accesso/cancellazione GDPR): procedura referenziata.
- [ ] Se HIPAA/finance: requisiti specifici verificati; tier critical (L0) + review dedicata.

**Non-Negotiable:** eredita NN#1 (RLS su tabelle con PII) e NN#3 (secrets/crittografia).

**Stop condition:** se non è chiaro se un dato è PII o quale base giuridica/retention si applichi, fermati
e coinvolgi l'owner/DPO; non trattare dati regolati per inferenza.
