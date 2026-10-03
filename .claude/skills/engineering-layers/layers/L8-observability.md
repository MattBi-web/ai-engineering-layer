# L8 — Observability

**Scopo:** in produzione sai cosa succede e te ne accorgi *prima* degli utenti.

**Decisioni di default:** 4 Golden Signals per ogni servizio. SLO con error budget. Tracing distribuito
(OpenTelemetry). Alert sul *burn rate* dell'error budget, non sul singolo errore.

**Checklist:**
- [ ] **4 Golden Signals** esposti: latency, traffic, errors, saturation.
- [ ] SLI definiti + SLO con error budget per il servizio/endpoint.
- [ ] Logging strutturato con context (trace/span id); niente PII/secret nei log.
- [ ] Tracing distribuito propagato attraverso i confini di servizio (OpenTelemetry).
- [ ] Alerting su burn rate dell'error budget (non un alert per ogni 500).
- [ ] Dashboard minima o metriche esportate per il nuovo componente.

**Non-Negotiable:** nessuna (ma è il layer che Lovable & co. saltano sistematicamente).

**Stop condition:** se non esistono SLO/target per il servizio, fermati e concordali prima di dichiarare "production-ready".
