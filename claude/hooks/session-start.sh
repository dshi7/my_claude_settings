#!/usr/bin/env bash
# SessionStart hook: inject hostname and GPU type into Claude's context.

set -euo pipefail

INPUT=$(cat)
HOST=$(hostname -s 2>/dev/null || hostname)

# Detect GPU type if nvidia-smi is available
GPU=""
if command -v nvidia-smi &>/dev/null; then
  GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 | xargs)
fi

if [ -n "$GPU" ]; then
  CONTEXT="Devserver: ${HOST} (GPU: ${GPU})"
else
  CONTEXT="Devserver: ${HOST} (no GPU)"
fi

# Check if this is a post-compaction restart — re-inject project context
SOURCE=$(echo "$INPUT" | jq -r '.source // ""')
STATE_FILE="$HOME/.claude/.active-project"

if [[ "$SOURCE" == "compact" ]] && [[ -f "$STATE_FILE" ]]; then
  PROJ=$(cat "$STATE_FILE")
  PROJ_FILE="$HOME/.claude/internal/${PROJ}.md"
  if [[ -f "$PROJ_FILE" ]]; then
    PROJ_CONTEXT=$(cat "$PROJ_FILE")
    CONTEXT="${CONTEXT}. Active project: ${PROJ}. Re-injecting context after compaction. ${PROJ_CONTEXT}"
  fi
else
  # Remind about /project in fbsource/fbcode
  CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
  if [[ "$CWD" == */fbsource* ]] || [[ "$CWD" == */fbcode* ]]; then
    CONTEXT="${CONTEXT}. Tip: run /project to load project context."
  fi
fi

jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
