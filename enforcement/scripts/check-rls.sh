#!/usr/bin/env bash
# NN#1 — RLS/authz on every non-public table. Heuristic, portable (bash 3.2+).
#
# Case A — repo with SQL migrations: every CREATE TABLE must have ENABLE ROW LEVEL SECURITY + CREATE POLICY
#          in the same migration. Exemption: comment "-- rls-exempt: <reason>".
# Case B — repo WITHOUT SQL that still accesses tables (Supabase client / ORM): RLS lives in Supabase and CANNOT
#          be verified from code. A tracked ATTESTATION is required: file governance/rls-attestation.md
#          or an "RLS: enabled" marker in governance/data-inventory.md. No attestation → finding.
#
# Usage: check-rls.sh [file.sql ...]   (pre-commit passes the modified .sql files; with no arguments it audits the repo)
set -euo pipefail
fail=0

check_sql_file() {
  local f="$1" tbl
  [ -f "$f" ] || return 0
  grep -qiE '^\s*--\s*rls-exempt' "$f" && return 0
  while IFS= read -r tbl; do
    [ -z "$tbl" ] && continue
    grep -qiE 'enable row level security' "$f" || { echo "❌ [NN#1] $f: table '$tbl' without ENABLE ROW LEVEL SECURITY"; fail=1; }
    grep -qiE 'create policy' "$f" || { echo "❌ [NN#1] $f: table '$tbl' without CREATE POLICY"; fail=1; }
  done < <(grep -ioE 'create table (if not exists )?["a-z0-9_.]+' "$f" | sed -E 's/.* //; s/"//g')
}

# Collect the SQL files to check
sqls=("$@")
if [ ${#sqls[@]} -eq 0 ]; then
  sqls=(); while IFS= read -r _l; do sqls+=("$_l"); done < <(find . -path ./node_modules -prune -o -name '*.sql' -print 2>/dev/null)
fi

if [ ${#sqls[@]} -gt 0 ]; then
  # Case A
  for f in ${sqls[@]+"${sqls[@]}"}; do check_sql_file "$f"; done
else
  # Case B — no SQL migrations: does the repo access tables via Supabase/ORM?
  # UNAMBIGUOUS signals of DB table ownership (avoids false positives: a Pydantic BaseModel is NOT a table)
  uses_tables=$(grep -rlE '\.table\(|\.from_\(|__tablename__|declarative_base\(|SQLModel,\s*table\s*=\s*True' --include='*.py' . 2>/dev/null | grep -vE 'node_modules|\.venv|/_backup|/_wip' | head -1 || true)
  if [ -n "$uses_tables" ]; then
    if grep -rqiE 'RLS[:= ]+(enabled|attiva|on|true)|rls-attested' governance/rls-attestation.md governance/data-inventory.md 2>/dev/null; then
      echo "✅ [NN#1] no SQL migrations; table access present but RLS ATTESTED (see governance/)."
    else
      echo "🔶 [NN#1] the repo accesses tables (Supabase/ORM) but there are no SQL migrations with verifiable RLS,"
      echo "         nor an attestation. → Confirm RLS in Supabase and document it in governance/rls-attestation.md"
      echo "         (or mark 'RLS: enabled' for each table in governance/data-inventory.md)."
      fail=1
    fi
  else
    echo "✅ [NN#1] no tables detected (neither SQL nor Supabase/ORM access)."
  fi
fi

[ $fail -eq 0 ] && echo "✅ [NN#1] RLS ok" || echo "→ RLS+policy in the migrations (case A) or a tracked attestation (case B)."
exit $fail
