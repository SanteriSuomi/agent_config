---
name: worktrunk
description: "Git worktree management for parallel agent workflows. Use proactively when parallel work streams are needed or when isolating experimental changes. Also use when users ask about worktrees, parallel branches, or isolated workspaces."
---

# Worktrunk

Git worktree management CLI. Enables parallel agents in isolated workspaces.

## Installation

```bash
# macOS/Linux
brew install max-sixty/worktrunk/wt && wt config shell install

# Windows
winget install max-sixty.worktrunk
git-wt config shell install

# Cross-platform
cargo install worktrunk && wt config shell install
```

## Commands

| Command | Purpose |
|---------|---------|
| `wt switch -c feat` | Create worktree for new branch |
| `wt switch -c -x claude feat` | Create worktree + launch Claude |
| `wt switch feat` | Switch to existing worktree |
| `wt list` | Show all worktrees with status |
| `wt remove feat` | Cleanup worktree + delete branch |
| `wt merge` | Squash + rebase + merge + cleanup |

## Parallel Agent Workflow

```bash
# Terminal 1: Agent working on auth
wt switch -c -x claude feat-auth

# Terminal 2: Agent working on API
wt switch -c -x claude feat-api

# Terminal 3: Agent working on UI
wt switch -c -x claude feat-ui

# Each agent has isolated workspace, shared git history
```

## With Sandbox

```bash
wt switch -c feat-new
./sandbox/start-sandbox.sh
./scripts/agent-loop.sh --max-iterations 10
```

## Merge Workflow

```bash
# After feature complete
wt merge
# Squashes commits, rebases, merges to base, cleans up worktree
```

## When to Use

- Running multiple AI agents in parallel
- Feature isolation without separate clones
- Quick context switching between features
- Agent-loop with isolated workspaces

## When NOT to Use

- Single-agent sequential work
- Projects without git
- When disk space is critical (worktrees share objects)
