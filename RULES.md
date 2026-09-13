# RULES.md

Universal behavioral rules, shared by every agent consuming this repo — OpenCode (via `AGENTS.md`) and Hermes (via its `SOUL.md` pointer). Read and follow these every session.

## Shared Config Layout

```
~/agent_config/             # Source of truth (Fedora; ~/.agents/ on Windows)
├── AGENTS.md               # OpenCode entry file (OpenCode-specific config)
├── RULES.md                # This file — universal rules for all agents
├── context/                # Shared knowledge base + memory log (see Context Router)
├── skills/                 # Skills shared by all agents (SKILL.md format)
├── agents/                 # OpenCode subagents (researcher)
├── commands/               # OpenCode slash commands (scaffolding)
└── config/                 # OpenCode tool configs: opencode.json (providers, plugin), omo.jsonc
```

**IMPORTANT:** Always modify files in the source-of-truth dir (`~/agent_config/` on Fedora, `~/.agents/` on Windows) — never in symlink targets. Changes propagate automatically.

## Code

- Show full file paths when in git worktrees or similar
- Explicit named imports, no wildcards or barrel files
- Case-sensitive paths always
- Strict mode, type-safe code
- Types must accurately reflect reality (optional fields should be `?`, nullable fields should include `| null`)
- Omit explicit return types unless needed for clarity or compiler requirements
- Pin exact dependency versions: `"1.8.0"` not `"^1.8.0"`. Let lockfiles handle reproducibility.
- Pin exact versions in Dockerfiles and install scripts (e.g. `ansible-core==2.20.4`, `sops-v3.13.1`). Verify latest stable version via web search before pinning.

## Comments

**Only for:** exotic functions, workarounds, complex algorithms, "why" explanations.
**Never:** obvious code, redundant descriptions.

## Commits

- Imperative form ("Add feature" not "Added feature")
- Only commit when explicitly asked
- Run tests/lint first
- NEVER add watermarks, signatures, or "Co-Authored-By" lines
- **One commit per branch/PR** — squash all work into a single commit before pushing. Amend as work progresses. Unless explicitly told otherwise, never leave multiple commits on a feature branch.

## Git

- Prefer `git pull --rebase` over `git pull` to avoid merge commits
- **One agent = one worktree.** Never let two agents edit the same checkout concurrently; create a worktree before touching a shared repo from a second agent.

## Testing

After changes, run in order (fail fast):
1. Type check → 2. Lint → 3. Unit tests → 4. Integration tests

**Web/UI/game deliverables are not done until verified in a real browser** — never claim "tested" without executing these steps:
1. Serve the app with a persistent process via the `pm2` skill (no ad-hoc backgrounded servers)
2. Drive it with the `playwright-cli` skill: load page, check console for errors, exercise the core user flow (clicks, input, state transitions), screenshot the result
3. Inspect screenshots visually (vision tool) — confirm the UI actually renders, not just that the DOM exists
4. Kill the pm2 process when done unless the user wants it kept running

Browser automation rules: always use the `playwright-cli` skill (never raw Playwright scripts), always with named sessions (`-s=<name>`) for isolation when multiple agents may run in parallel.

## Anti-Patterns

- Only make requested changes
- No unrequested features or refactoring
- No abstractions for one-time operations
- No error handling for impossible cases
- No hypothetical future design
- Three similar lines > premature abstraction

## Writing (Anti-Slop)

**Avoid:** throat-clearing ("In order to..."), emphasis crutches ("significantly"), tripling (always 3 items), AI words (delve, crucial, leverage, utilize, seamless, robust).

**Do:** Be specific, direct, varied rhythm. Have opinions. Acknowledge uncertainty.

## Web Search

Use current year (2026) in all searches.

## Boundaries

**Always:** Run tests before commits, read files before modifying
**Ask First:** New dependencies, major refactors, architecture changes, deleting files
**Never:** Commit secrets, force push main, guess file contents, fabricate tool results
**Never:** Take actions on Santeri's accounts (GitHub, social media, email, forums) — posting, commenting, publishing, PRs, messages — without explicit approval for that specific action. Reading/fetching is fine. Creating/publishing = ask first.

## Context Router (MiniPC only — read on demand, not at session start)

`~/agent_config/context/` is the living knowledge base for the Fedora media server. **You are explicitly allowed — and expected — to update these files** whenever you change infrastructure, learn something durable, or find stale info. No need to ask. Don't rewrite history in memory files.

- `context/network.md` — IPs, DNS (CoreDNS), reverse proxy (Caddy, all-HTTP policy), Tailscale, VPN, remote access. Read for: anything network/URL/firewall related.
- `context/services.md` — service catalog (subdomains, ports, containers), Plex quirks, custom containers. Read for: work on the docker stack / compose.yml.
- `context/storage.md` — disks, NAS mounts, key paths. Read for: file locations, disk space work.
- `context/llm.md` — GPU, llama-server config/flags, safety limits, bench methodology. Read for: any LLM/GPU task.
- `context/media.md` — media stack, Stash/XBVR layout, funscript workflow pointer, Handy. Read for: media/NSFW tasks.
- `context/credentials.md` — account credentials (gitignored). Read only when a task needs them; never log or commit.
- `context/user.md` — about Santeri. Read when personal context matters.
- `context/memory/YYYY-MM.md` — dated incident/change history. **Append** new entries to the current month file (create when a month turns); never rewrite old entries. Read when history/past incidents matter.
