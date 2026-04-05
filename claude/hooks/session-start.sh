#!/usr/bin/env bash
# SessionStart hook: inject current hostname into Claude's context.
# Useful on devservers where you may have multiple machines.

set -euo pipefail

HOST=$(hostname -s 2>/dev/null || hostname)

jq -n --arg host "$HOST" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("Devserver hostname: " + $host)
  }
}'

exit 0
