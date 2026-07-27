#!/usr/bin/env bash
# github-kb.sh — shared knowledge-base CLI backed by a plain GitHub repo (Outline alternative).
# Prefer this over the GitHub API: plain git clone/pull/commit/push, no rate limits, same tool
# already used everywhere else in this harness. Auth relies on the existing `gh`/git credential
# helper — no separate token to manage.
#
# Repo layout: <repo-root>/<project>/{fails,best-practices,tricks,daily-status}/*.md
# (mirrors Outline's Knowledge Base sub-pages, grouped by originating project first)
#
# Usage:
#   github-kb.sh sync                                          — clone (if missing) or pull the cache
#   github-kb.sh search "<query>" [project] [category]         — grep across cache (pulls first)
#   github-kb.sh get <path-relative-to-repo-root>               — print a file's content
#   github-kb.sh publish <project> <category> <slug> < body.md — write + commit + push
#   github-kb.sh ping                                           — verify repo reachable
#
# Required env (set by the caller from .claude/.setup.json outline.github_repo / github_cache_dir):
#   GITHUB_KB_REPO        — "owner/repo"
#   GITHUB_KB_CACHE_DIR   — local clone path, default ~/.claude/kb-github-cache

set -euo pipefail

: "${GITHUB_KB_REPO:?GITHUB_KB_REPO env var not set. Read outline.github_repo from .claude/.setup.json first.}"
: "${GITHUB_KB_CACHE_DIR:=$HOME/.claude/kb-github-cache}"

_sync() {
  if [ -d "$GITHUB_KB_CACHE_DIR/.git" ]; then
    git -C "$GITHUB_KB_CACHE_DIR" pull --quiet --ff-only
  else
    mkdir -p "$(dirname "$GITHUB_KB_CACHE_DIR")"
    gh repo clone "$GITHUB_KB_REPO" "$GITHUB_KB_CACHE_DIR" -- --quiet
  fi
}

case "${1:-}" in
  sync)
    _sync
    echo "OK: $GITHUB_KB_CACHE_DIR synced with $GITHUB_KB_REPO"
    ;;
  search)
    query="${2:?query required}"
    project="${3:-}"
    category="${4:-}"
    _sync
    scope="$GITHUB_KB_CACHE_DIR"
    [ -n "$project" ] && scope="$scope/$project"
    [ -n "$category" ] && scope="$scope/$category"
    grep -rli "$query" "$scope" 2>/dev/null | sed "s|$GITHUB_KB_CACHE_DIR/||" || { echo "no matches"; exit 0; }
    ;;
  get)
    path="${2:?path required (relative to repo root)}"
    _sync
    cat "$GITHUB_KB_CACHE_DIR/$path"
    ;;
  publish)
    project="${2:?project required}"
    category="${3:?category required (fails|best-practices|tricks|daily-status)}"
    slug="${4:?slug required (filename without .md)}"
    _sync
    dest="$GITHUB_KB_CACHE_DIR/$project/$category"
    mkdir -p "$dest"
    cat > "$dest/$slug.md"
    git -C "$GITHUB_KB_CACHE_DIR" add "$project/$category/$slug.md"
    git -C "$GITHUB_KB_CACHE_DIR" commit -q -m "$project: $category/$slug" || { echo "nothing to commit"; exit 0; }
    # one retry on push conflict — multiple projects/sessions can write concurrently
    if ! git -C "$GITHUB_KB_CACHE_DIR" push --quiet; then
      git -C "$GITHUB_KB_CACHE_DIR" pull --quiet --rebase
      git -C "$GITHUB_KB_CACHE_DIR" push --quiet
    fi
    echo "OK: published $project/$category/$slug.md"
    ;;
  ping)
    gh repo view "$GITHUB_KB_REPO" >/dev/null 2>&1 && echo "OK" || { echo "FAIL: repo unreachable or gh not authenticated" >&2; exit 1; }
    ;;
  *)
    sed -n '1,/^set -e/p' "$0" | sed -n '1,22p'
    exit 1
    ;;
esac
