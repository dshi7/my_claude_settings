#!/usr/bin/env bash
# SessionStart hook: inject hostname and GPU type into Claude's context.

set -euo pipefail

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

jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
