#!/usr/bin/env bash
# worktree.sh — Manage git worktrees for step-based development
#
# Usage:
#   worktree.sh create <step> [name]  — Create worktree + branch
#   worktree.sh remove <step>         — Remove worktree + delete branch
#   worktree.sh merge <step>          — Squash-merge into current branch
#   worktree.sh list                  — List active worktrees
#
# Examples:
#   worktree.sh create 15 settings    → branch: step-15-settings, path: ../step15-settings
#   worktree.sh create 3              → branch: step-3, path: ../step3
#   worktree.sh remove 15
#   worktree.sh merge 15
#   worktree.sh list

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [[ -z "$MAIN_ROOT" ]]; then
    echo "Error: not inside a git repository" >&2
    exit 1
fi
PARENT_DIR="$(dirname "$MAIN_ROOT")"
BASENAME="$(basename "$MAIN_ROOT")"

usage() {
    sed -n '2,/^$/p' "$0" | sed 's/^# //' | sed 's/^#//'
    exit 1
}

branch_name() {
    local step="$1"
    local name="${2:-}"
    if [[ -n "$name" ]]; then
        echo "step-${step}-${name}"
    else
        echo "step-${step}"
    fi
}

worktree_path() {
    local step="$1"
    local name="${2:-}"
    if [[ -n "$name" ]]; then
        echo "${PARENT_DIR}/${BASENAME}-step${step}-${name}"
    else
        echo "${PARENT_DIR}/${BASENAME}-step${step}"
    fi
}

cmd_create() {
    local step="$1"
    local name="${2:-}"
    local branch
    branch="$(branch_name "$step" "$name")"
    local path
    path="$(worktree_path "$step" "$name")"

    if ! [[ "$step" =~ ^[0-9]+$ ]]; then
        echo "Error: step number must be numeric, got: $step" >&2
        exit 1
    fi

    if [[ -d "$path" ]]; then
        echo "Error: directory already exists: $path" >&2
        echo "Use 'remove' first, or manually investigate." >&2
        exit 1
    fi

    if git show-ref --verify --quiet "refs/heads/${branch}"; then
        echo "Error: branch '${branch}' already exists." >&2
        echo "Use 'remove' first if you want to recreate." >&2
        exit 1
    fi

    echo "=== Creating worktree ==="
    echo "  Branch: ${branch}"
    echo "  Path:   ${path}"
    echo ""

    git worktree add -b "$branch" "$path" HEAD

    echo ""
    echo "=== Copying .env ==="
    if [[ -f "${MAIN_ROOT}/.env" ]]; then
        cp "${MAIN_ROOT}/.env" "${path}/.env"
    else
        echo "  Warning: no .env found in main worktree"
    fi

    echo "=== Installing dependencies ==="
    if [[ -f "${path}/package.json" ]]; then
        pnpm.cmd install --dir "$path" 2>/dev/null || pnpm install --dir "$path"
    else
        echo "  No package.json found, skipping"
    fi

    echo "=== Initializing database ==="
    if [[ -f "${path}/drizzle.config.ts" ]]; then
        MSYS_NO_PATHCONV=1 npx.cmd drizzle-kit push --force --config="${path}/drizzle.config.ts" 2>/dev/null \
            || MSYS_NO_PATHCONV=1 npx drizzle-kit push --force --config="${path}/drizzle.config.ts" \
            || echo "  Warning: drizzle-kit push failed"
    else
        echo "  No drizzle.config.ts found, skipping"
    fi

    echo "=== Generating paraglide files ==="
    if [[ -d "${path}/project.inlang" ]]; then
        MSYS_NO_PATHCONV=1 npx.cmd @inlang/paraglide-js compile --project "${path}/project.inlang" --outdir "${path}/src/lib/paraglide" 2>/dev/null \
            || MSYS_NO_PATHCONV=1 npx @inlang/paraglide-js compile --project "${path}/project.inlang" --outdir "${path}/src/lib/paraglide" \
            || echo "  Warning: paraglide compile failed"
    else
        echo "  No project.inlang found, skipping"
    fi

    echo ""
    echo "=== Worktree ready ==="
    echo "  cd ${path}"
    echo "  pnpm dev"
    echo ""
    echo "  Or start dev server with pm2:"
    echo "  npx pm2 start scripts/pm2-dev.mjs --name step-${step}"
}

cmd_remove() {
    local step="$1"
    local name="${2:-}"
    local path
    path="$(worktree_path "$step" "$name")"

    if [[ ! -d "$path" ]]; then
        echo "Warning: directory not found: ${path}, pruning stale refs" >&2
        git worktree prune
        local branch
        branch="$(branch_name "$step" "$name")"
        if git show-ref --verify --quiet "refs/heads/${branch}"; then
            echo "Deleting orphan branch: ${branch}"
            git branch -D "$branch" 2>/dev/null || true
        fi
        exit 0
    fi

    echo "=== Removing worktree: ${path} ==="
    if ! git worktree remove --force "$path" 2>/dev/null; then
        echo "  git worktree remove failed (Windows file lock?), forcing directory removal"
        rm -rf "$path" 2>/dev/null || true
    fi

    echo "=== Pruning stale worktree metadata ==="
    git worktree prune

    local branch
    branch="$(branch_name "$step" "$name")"
    if git show-ref --verify --quiet "refs/heads/${branch}"; then
        echo "=== Deleting branch: ${branch} ==="
        git branch -D "$branch" 2>/dev/null || true
    fi

    echo "Done."
}

cmd_merge() {
    local step="$1"
    local name="${2:-}"
    local branch
    branch="$(branch_name "$step" "$name")"
    local path
    path="$(worktree_path "$step" "$name")"

    if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
        echo "Error: branch '${branch}' not found" >&2
        exit 1
    fi

    echo "=== Squash-merging ${branch} into $(git branch --show-current) ==="
    git merge --squash "$branch"

    echo ""
    echo "Squash merge staged. Review with 'git diff --cached', then commit."
    echo "After committing:"
    echo "  ~/.agents/scripts/worktree.sh remove ${step} ${name}"
}

cmd_list() {
    echo "=== Active worktrees ==="
    git worktree list
    echo ""
}

if [[ $# -lt 1 ]]; then
    usage
fi

command="$1"
shift

case "$command" in
    create)
        [[ $# -lt 1 ]] && { echo "Usage: worktree.sh create <step> [name]"; exit 1; }
        cmd_create "$@"
        ;;
    remove)
        [[ $# -lt 1 ]] && { echo "Usage: worktree.sh remove <step> [name]"; exit 1; }
        cmd_remove "$@"
        ;;
    merge)
        [[ $# -lt 1 ]] && { echo "Usage: worktree.sh merge <step> [name]"; exit 1; }
        cmd_merge "$@"
        ;;
    list)
        cmd_list
        ;;
    *)
        echo "Unknown command: ${command}" >&2
        usage
        ;;
esac
