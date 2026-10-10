# Runbook — <service name>

- **Owner / on-call:** <owner / rotation>
- **Repo / deploy:** <link>  · **Dashboard:** <link>  · **Alert channel:** <#channel>

## What it does
A 2-3 line description. Upstream/downstream dependencies.

## Health & SLO (L8)
- Health check: `GET /health` → 200
- SLO: e.g. 99.9% availability, p95 latency < 300ms, error rate < 0.5%
- 4 Golden Signals: where to read them (latency / traffic / errors / saturation)

## Alert response
| Alert | Likely cause | First action | Escalation |
|---|---|---|---|
| Error budget burn | … | check dashboard X | @owner after 15' |
| High p95 latency | … | check DB/queue | … |

## Deploy & Rollback (L9)
- Deploy: <command / pipeline>
- Rollback: <command / procedure> — target RTO: <…>
- Relevant feature flags: <…>

## Common incidents
- **Symptom →** diagnosis → step-by-step fix.

## Escalation
SEV1/SEV2/SEV3: who to call, and within how long. Link to the postmortem template.
