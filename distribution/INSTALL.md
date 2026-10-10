# AI Engineering Layer — Installation

Full setup of an "anti vibe-coding" Claude Code environment with smart retrieval. One line.

## One-liner
**Public repo** (curl works as-is):
```bash
curl -fsSL https://raw.githubusercontent.com/MattBi-web/ai-engineering-layer/master/distribution/install.sh | bash
```
**Private repo** (curl needs auth → use `gh repo clone`, still one line):
```bash
gh repo clone MattBi-web/ai-engineering-layer ~/Dev/ai-engineering-layer && bash ~/Dev/ai-engineering-layer/distribution/install.sh
```

Full options (Obsidian + nightly routine):
```bash
curl -fsSL <URL>/install.sh | bash -s -- --with-obsidian "$HOME/Documents/Memoria_AI" --with-reindex-routine
```

> The script is **idempotent** (safe to re-run), supports a **dry run** with `--dry-run`, and
> **never overwrites** your existing settings — it only merges where needed.

## What it installs
| Component | Always | Opt-in |
|---|---|---|
| Claude Code plugin `agent-skills` (28 skills + `/spec /plan /build /test /review /ship`) | ✅ | |
| MCP `codebase-memory` (code knowledge graph, -99% tokens on searches) | ✅ | |
| Default model `opusplan` + read-only permission allowlist | ✅ | |
| "Graph-first" rule + subagent routing in `~/.claude/CLAUDE.md` | ✅ | |
| Framework template in `~/Dev/ai-engineering-layer` (governance, enforcement, 12 layers) | ✅ | |
| MCP `obsidian` on a personal vault | | `--with-obsidian <path>` |
| Nightly launchd routine that re-indexes projects (macOS only) | | `--with-reindex-routine` |

## Windows users
Dedicated guide: [`INSTALL.windows.md`](INSTALL.windows.md). Two paths: **WSL2 Ubuntu** (recommended: same command as Mac/Linux) or **native Windows** with the PowerShell installer `install.ps1` (equivalent one-liner).

## Prerequisites
- **Claude Code** installed (`claude` on `PATH`).
- **Node 18+** (for `npm`, `npx`).
- **git**, **jq**, **bash**.
- Native macOS or Linux. Windows → see [`INSTALL.windows.md`](INSTALL.windows.md).

## After installation
1. **Restart Claude Code** (`/exit`, then relaunch) to load the plugin and the new settings.
2. In a session you'll see the new commands: `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`, `/code-simplify`.
3. **Index one of your projects** (first time, in Claude Code):
   *"Index this project"* — Claude will call the `index_repository` tool automatically.
   From then on it explores code with `search_graph` / `trace_path` / `get_architecture`
   instead of grep — fewer tokens, no hallucinations.

## What to use when
- **Research chats, questions, ideas** → nothing to do: opusplan + memory + MCP run in the background.
- **Working on an indexed project** → graph-first kicks in on its own.
- **Building a feature / serious refactor** → use the agent-skills `/spec → /ship` loop.
- **Critical repo (auth, payments, PII, production client code)** → drop the **framework template** into that repo (3 enforcement rings that block unsafe merges).

## Enabling the "hard" guardrails on a target repo
```bash
FW="$HOME/Dev/ai-engineering-layer"
cd <repo>
cp "$FW/.github/PULL_REQUEST_TEMPLATE.md" .github/
cp "$FW/.github/workflows/non-negotiables.yml" .github/workflows/
cp -r "$FW/enforcement" ./
cp "$FW/enforcement/.pre-commit-config.yaml" .pre-commit-config.yaml
pre-commit install
```
From then on every commit/PR is gated on the 3 Non-Negotiables: **RLS** (every table), **rate limiting**
(every public endpoint), **secrets** (never committed).

## Troubleshooting
- *"jq required"*: `brew install jq` (macOS) or `apt-get install jq` (Linux).
- *Plugin not visible*: did you restart Claude Code? Check with `claude plugin list`.
- *MCP not responding*: `claude mcp list` → both must show `✓ Connected`.
- *Obsidian vault rejected*: the server requires a `.obsidian/` config. The installer creates a minimal one if missing.

## Uninstall
```bash
claude plugin uninstall agent-skills
claude mcp remove codebase-memory
claude mcp remove obsidian        # if installed
# (optional) launchctl unload "$HOME/Library/LaunchAgents/com.aengl.reindex.plist"
# your other keys in ~/.claude/settings.json and ~/.claude/CLAUDE.md stay untouched
```

## Security & privacy
- Everything runs locally. No data leaves your machine (apart from the regular Anthropic API calls you already make with Claude Code).
- The `agent-skills` plugin is MIT-licensed, 46k ⭐, and was inspected — its only network activity is a local WebFetch cache (ETag revalidation of the same URL you're already fetching).
- `codebase-memory-mcp` is a local, statically linked single binary.
