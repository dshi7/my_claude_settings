#!/usr/bin/env bash
# CwdChanged hook: detect VCS when Claude changes directory.
# Writes REPO_VCS=hg|git|none to CLAUDE_ENV_FILE so downstream
# hooks and commands can check it without re-detecting.

set -euo pipefail

INPUT=$(cat)
NEW_CWD=$(echo "$INPUT" | jq -r '.new_cwd // ""')

if [ -z "${CLAUDE_ENV_FILE:-}" ] || [ -z "$NEW_CWD" ]; then
  exit 0
fi

VCS=none
if cd "$NEW_CWD" 2>/dev/null; then
  if hg root &>/dev/null 2>&1; then
    VCS=hg
  elif git rev-parse --git-dir &>/dev/null 2>&1; then
    VCS=git
  fi
fi

echo "export REPO_VCS=$VCS" >> "$CLAUDE_ENV_FILE"

exit 0
