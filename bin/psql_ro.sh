#!/usr/bin/env bash
# psql_ro.sh — read-only psql wrapper for production DB queries.
# Enforces statement timeout and read-only transactions.
#
# Usage:
#   psql_ro.sh "SELECT id, status FROM campaign_drafts WHERE client_id=42 LIMIT 10"
#
# Requires (set in docs/STACK.md or ~/.zshrc per project):
#   PROD_SSH_ALIAS    — e.g. slugger
#   PROD_DB_CONTAINER — e.g. slugger-db-1
#   PROD_DB_USER      — e.g. slugger
#   PROD_DB_NAME      — e.g. slugger_crm

set -euo pipefail

: "${PROD_SSH_ALIAS:?PROD_SSH_ALIAS not set. Configure in docs/STACK.md or ~/.zshrc.}"
: "${PROD_DB_CONTAINER:?PROD_DB_CONTAINER not set.}"
: "${PROD_DB_USER:?PROD_DB_USER not set.}"
: "${PROD_DB_NAME:?PROD_DB_NAME not set.}"

QUERY="${1:?SQL query required}"

# Reject obvious write attempts at the wrapper level (defense in depth — server enforces RO too).
if echo "$QUERY" | grep -iqE '\b(drop|delete|truncate|insert|update|alter|create|grant|revoke)\b'; then
  echo "FAIL: write keyword detected. Use psql_rw.sh for writes." >&2
  exit 1
fi

# Wrap in 5s timeout + read-only transaction. Server-side defense.
PREFIX="SET statement_timeout=5000; SET default_transaction_read_only=on;"

ssh "$PROD_SSH_ALIAS" \
  "sudo docker exec $PROD_DB_CONTAINER psql -U $PROD_DB_USER -d $PROD_DB_NAME \
    -v ON_ERROR_STOP=1 \
    -c \"$PREFIX $QUERY\""
