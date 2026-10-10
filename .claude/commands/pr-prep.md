---
description: Prepare the PR — runs the 3 Non-Negotiables and the per-layer checklist, and fills in the PR template
argument-hint: (optional) target branch, default main
---

Prepare the Pull Request for the current changes. Target: **${ARGUMENTS:-main}**.

> This is the **merge gate** (3 Non-Negotiables + layer declaration + template completion), NOT the code
> review: for review use agent-skills' `/review` (fan-out code-reviewer/security-auditor/test-engineer).

### 1. Collect the diff
`git diff --stat ${ARGUMENTS:-main}...HEAD` and `git diff ${ARGUMENTS:-main}...HEAD` to see what changes.

### 2. 3 Non-Negotiables (BEFORE anything else — if one fails: immediate NO-GO)
- **NN#1 RLS**: every new/modified table has `ENABLE ROW LEVEL SECURITY` + `CREATE POLICY` in the same migration.
- **NN#2 Rate limit**: every new public endpoint has rate limiting.
- **NN#3 Secrets**: no secrets in tracked files; `.env` ignored; no plaintext API keys.
(If the repo has `enforcement/scripts/`, run them; otherwise verify manually against the diff.)

### 3. Detect the touched layers and apply the checklists
From the diff, infer which layers L0–L11 are involved. For EACH one, load its sheet from the
`engineering-layers` skill and check the checklist against the diff. List the items satisfied and those missing.

### 4. Tier
Classify the PR: **cosmetic** / **standard** / **critical** (auth, payment, PII, migrations → critical
= requires ≥2 human reviews + security scan).

### 5. Self-review → then a separate reviewer
Generate the **compliance report**: what was done, what was NOT done, where assumptions were
made. For `standard`/`critical` PRs, recommend running Step 5 with a separate `opus` subagent.

### 6. Fill in the PR template
Fill in `.github/PULL_REQUEST_TEMPLATE.md`: tick only the touched layers, complete their sections, the 3 NNs,
the AI-specific checks and the architecture notes. Return the markdown ready to paste.
