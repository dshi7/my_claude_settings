#!/usr/bin/env bash
# PreToolUse hook: block commit, amend, and force-push commands.
# Enforces the preference: "leave changes uncommitted for me to review."

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Block commit/amend commands across all VCS tools
if echo "$COMMAND" | grep -qE '^(sl|hg|git)\s+(commit|amend)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: do not commit or amend. Leave changes uncommitted for user to review."
    }
  }'
  exit 0
fi

# Block force-push
if echo "$COMMAND" | grep -qE '^git\s+push\s+.*--force'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: force-push is not allowed."
    }
  }'
  exit 0
fi

# Block jf submit (code review submission)
if echo "$COMMAND" | grep -qE '^jf\s+submit\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: do not submit diffs. Leave for user to review and submit."
    }
  }'
  exit 0
fi

exit 0
