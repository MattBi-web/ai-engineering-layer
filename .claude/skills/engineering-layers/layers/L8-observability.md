# L8 — Observability

**Purpose:** in production you know what is happening and notice problems *before* users do.

**Default decisions:** 4 Golden Signals for every service. SLOs with an error budget. Distributed tracing
(OpenTelemetry). Alerts on the error budget *burn rate*, not on individual errors.

**Checklist:**
- [ ] **4 Golden Signals** exposed: latency, traffic, errors, saturation.
- [ ] SLIs defined + SLOs with an error budget for the service/endpoint.
- [ ] Structured logging with context (trace/span id); no PII/secrets in logs.
- [ ] Distributed tracing propagated across service boundaries (OpenTelemetry).
- [ ] Alerting on error budget burn rate (not one alert per 500).
- [ ] Minimal dashboard or exported metrics for the new component.

**Non-Negotiable:** none (but this is the layer Lovable & co. systematically skip).

**Stop condition:** if there are no SLOs/targets for the service, stop and agree on them before declaring it "production-ready".
