# L7 — Performance & Scale

**Scopo:** il sistema risponde entro budget e regge la crescita di carico e dati.

**Decisioni di default:** performance budget per endpoint (p95). Cache dove serve (con invalidazione chiara).
CDN per asset statici. Decisioni di scaling (read replica, sharding) prese sui dati, non a caso.

**Checklist:**
- [ ] Performance budget definito (es. p95 < 300ms) e verificato per le path calde.
- [ ] Query DB indicizzate; niente N+1; paginazione su liste potenzialmente grandi.
- [ ] Caching con strategia di invalidazione esplicita (non cache "che non scade mai").
- [ ] Asset statici via CDN; payload compressi.
- [ ] Crescita dati: scelta motivata su read replica / sharding key / partizionamento; consistenza dichiarata.
- [ ] Load/performance test per i cambi su path critiche.

**Non-Negotiable:** nessuna (ma il rate-limit di L6 è il primo presidio anti-sovraccarico).

**Stop condition:** se non esistono target di performance o stime di carico, fermati e concordali prima
di ottimizzare (evita micro-ottimizzazioni premature).
