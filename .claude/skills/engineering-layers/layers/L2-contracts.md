# L2 — Contracts & API

**Scopo:** le interfacce tra componenti/servizi sono esplicite, tipizzate, versionate e stabili.

**Decisioni di default:** tipi/interfacce definiti PRIMA della logica (Step 2 del protocollo). OpenAPI per
le API HTTP. Tipi condivisi tra backend e frontend (generati o in `shared/`). Versioning esplicito sulle API pubbliche.

**Checklist:**
- [ ] Tipi/interfacce/schema definiti prima dell'implementazione; niente `any` (vedi L1/type safety).
- [ ] API HTTP documentata (OpenAPI/schema); request/response tipizzati.
- [ ] Contratto condiviso back↔front (tipi generati o in `shared/`), non duplicato a mano.
- [ ] API pubblica: versione esplicita (`/v1/…`) + policy di deprecation con timeline.
- [ ] Breaking change: gestito con versioning, non rompendo i consumer esistenti.
- [ ] Validazione del payload ai confini (vedi L5).

**Non-Negotiable:** nessuna.

**Stop condition:** se un contratto è ambiguo o un consumer esterno dipende dall'API, fermati e
concorda lo schema/versioning prima di implementare.
