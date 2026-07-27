#!/usr/bin/env bash
# outline.sh — minimal Outline API CLI fallback when MCP is not available.
# Prefer mcp__outline__* tools when MCP is configured (claude mcp list | grep outline).
#
# Usage:
#   outline.sh search "<query>" [collection_id]
#   outline.sh get <document_id>
#   outline.sh create <collection_id> <title> < body.md
#   outline.sh update <document_id> < body.md
#   outline.sh collections
#   outline.sh ping
#
# Required env (set in ~/.zshrc):
#   OUTLINE_TOKEN  — API key (https://your-outline.example.com/settings/api-keys)
#   OUTLINE_URL    — defaults to https://your-outline.example.com

set -euo pipefail

: "${OUTLINE_TOKEN:?OUTLINE_TOKEN env var not set. See ~/.zshrc.}"
: "${OUTLINE_URL:=https://your-outline.example.com}"

API="$OUTLINE_URL/api"
AUTH="Authorization: Bearer $OUTLINE_TOKEN"
CT="Content-Type: application/json"

call() {
  local endpoint="$1" data="$2"
  curl -sS --max-time 15 -X POST "$API/$endpoint" \
    -H "$AUTH" -H "$CT" -d "$data"
}

case "${1:-}" in
  search)
    q="${2:?query required}"
    coll="${3:-}"
    if [ -n "$coll" ]; then
      call documents.search "$(printf '{"query":"%s","collectionId":"%s","limit":10}' "$q" "$coll")"
    else
      call documents.search "$(printf '{"query":"%s","limit":10}' "$q")"
    fi
    ;;
  get)
    id="${2:?document id required}"
    call documents.info "$(printf '{"id":"%s"}' "$id")"
    ;;
  create)
    coll="${2:?collection id required}"
    title="${3:?title required}"
    body="$(cat | jq -Rs .)"
    call documents.create "$(printf '{"title":"%s","collectionId":"%s","text":%s,"publish":true}' "$title" "$coll" "$body")"
    ;;
  update)
    id="${2:?document id required}"
    body="$(cat | jq -Rs .)"
    call documents.update "$(printf '{"id":"%s","text":%s,"append":false}' "$id" "$body")"
    ;;
  collections)
    call collections.list '{"limit":50}'
    ;;
  ping)
    if call auth.info '{}' | grep -q '"data"'; then
      echo "OK"
    else
      echo "FAIL: token invalid or server unreachable" >&2
      exit 1
    fi
    ;;
  *)
    sed -n '1,/^set -e/p' "$0" | sed -n '1,20p'
    exit 1
    ;;
esac
