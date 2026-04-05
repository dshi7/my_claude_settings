#!/usr/bin/env bash
# PostCompact hook: append compact summary to workstreams.md so context
# survives across sessions.

set -euo pipefail

INPUT=$(cat)
SUMMARY=$(echo "$INPUT" | jq -r '.compact_summary // ""')
WORKSTREAMS="$HOME/.claude/internal/memory/workstreams.md"

# Only write if we have a summary and the file exists
if [ -z "$SUMMARY" ] || [ "$SUMMARY" = "null" ]; then
  exit 0
fi

if [ ! -f "$WORKSTREAMS" ]; then
  exit 0
fi

DATE=$(date +%Y-%m-%d)
printf '\n---\n## %s compact summary\n%s\n' "$DATE" "$SUMMARY" >> "$WORKSTREAMS"

exit 0
