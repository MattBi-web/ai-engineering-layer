#!/usr/bin/env bash
# NN#1 — RLS/authz su ogni tabella non pubblica. Euristico, portabile (bash 3.2+).
#
# Caso A — repo con migration SQL: ogni CREATE TABLE deve avere ENABLE ROW LEVEL SECURITY + CREATE POLICY
#          nella stessa migration. Eccezione: commento "-- rls-exempt: <motivo>".
# Caso B — repo SENZA SQL ma che accede a tabelle (Supabase client / ORM): la RLS vive su Supabase e NON è
#          verificabile dal codice. Si richiede un'ATTESTAZIONE tracciata: file governance/rls-attestation.md
#          o marcatura "RLS: enabled" in governance/data-inventory.md. Senza attestazione → finding.
#
# Uso: check-rls.sh [file.sql ...]   (pre-commit passa i .sql modificati; senza argomenti fa audit del repo)
set -euo pipefail
fail=0

check_sql_file() {
  local f="$1" tbl
  [ -f "$f" ] || return 0
  grep -qiE '^\s*--\s*rls-exempt' "$f" && return 0
  while IFS= read -r tbl; do
    [ -z "$tbl" ] && continue
    grep -qiE 'enable row level security' "$f" || { echo "❌ [NN#1] $f: tabella '$tbl' senza ENABLE ROW LEVEL SECURITY"; fail=1; }
    grep -qiE 'create policy' "$f" || { echo "❌ [NN#1] $f: tabella '$tbl' senza CREATE POLICY"; fail=1; }
  done < <(grep -ioE 'create table (if not exists )?["a-z0-9_.]+' "$f" | sed -E 's/.* //; s/"//g')
}

# Raccogli i file SQL da controllare
sqls=("$@")
if [ ${#sqls[@]} -eq 0 ]; then
  sqls=(); while IFS= read -r _l; do sqls+=("$_l"); done < <(find . -path ./node_modules -prune -o -name '*.sql' -print 2>/dev/null)
fi

if [ ${#sqls[@]} -gt 0 ]; then
  # Caso A
  for f in ${sqls[@]+"${sqls[@]}"}; do check_sql_file "$f"; done
else
  # Caso B — nessuna migration SQL: il repo accede a tabelle via Supabase/ORM?
  # Segnali UNIVOCI di proprietà di tabelle DB (evita falsi positivi: Pydantic BaseModel NON è una tabella)
  uses_tables=$(grep -rlE '\.table\(|\.from_\(|__tablename__|declarative_base\(|SQLModel,\s*table\s*=\s*True' --include='*.py' . 2>/dev/null | grep -vE 'node_modules|\.venv|/_backup|/_wip' | head -1 || true)
  if [ -n "$uses_tables" ]; then
    if grep -rqiE 'RLS[:= ]+(enabled|attiva|on|true)|rls-attested' governance/rls-attestation.md governance/data-inventory.md 2>/dev/null; then
      echo "✅ [NN#1] nessuna migration SQL; accesso a tabelle presente ma RLS ATTESTATA (vedi governance/)."
    else
      echo "🔶 [NN#1] il repo accede a tabelle (Supabase/ORM) ma non ci sono migration SQL con RLS verificabili,"
      echo "         né un'attestazione. → Conferma RLS su Supabase e documentala in governance/rls-attestation.md"
      echo "         (oppure marca 'RLS: enabled' per ogni tabella in governance/data-inventory.md)."
      fail=1
    fi
  else
    echo "✅ [NN#1] nessuna tabella rilevata (né SQL né accessi Supabase/ORM)."
  fi
fi

[ $fail -eq 0 ] && echo "✅ [NN#1] RLS ok" || echo "→ RLS+policy nelle migration (caso A) oppure attestazione tracciata (caso B)."
exit $fail
