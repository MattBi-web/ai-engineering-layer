# Runbook — <nome servizio>

- **Owner / on-call:** <team / rotazione>
- **Repo / deploy:** <link>  · **Dashboard:** <link>  · **Alert channel:** <#canale>

## Cosa fa
Una descrizione in 2-3 righe. Dipendenze a monte/valle.

## Health & SLO (L8)
- Health check: `GET /health` → 200
- SLO: es. 99.9% disponibilità, p95 latency < 300ms, error rate < 0.5%
- 4 Golden Signals: dove leggerli (latency / traffic / errors / saturation)

## Risposta agli alert
| Alert | Probabile causa | Prima azione | Escalation |
|---|---|---|---|
| Error budget burn | … | controlla dashboard X | @owner dopo 15' |
| Latency p95 alta | … | verifica DB/queue | … |

## Deploy & Rollback (L9)
- Deploy: <comando / pipeline>
- Rollback: <comando / procedura> — RTO target: <…>
- Feature flag rilevanti: <…>

## Incidenti comuni
- **Sintomo →** diagnosi → fix passo-passo.

## Escalation
SEV1/SEV2/SEV3: chi chiamare, entro quanto. Link al template postmortem.
