#!/bin/bash
# Install Claude settings into ~/.claude/
# Run from the git repo root.
#
# Usage:
#   ./install.sh              # copy OSS files only
#   ./install.sh --internal   # also copy internal configs + scaffold memory

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude settings from $SCRIPT_DIR -> $CLAUDE_DIR"

# Copy general CLAUDE.md
cp "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  copied CLAUDE.md"

# Copy rules (merge into existing rules/)
mkdir -p "$CLAUDE_DIR/rules"
for f in "$SCRIPT_DIR/claude/rules/"*; do
  [ -f "$f" ] || continue
  cp "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
  echo "  copied rules/$(basename "$f")"
done

# Optionally copy internal files
if [ "${1:-}" = "--internal" ] && [ -d "$SCRIPT_DIR/claude/internal" ]; then
  # Copy internal rules/configs
  mkdir -p "$CLAUDE_DIR/internal"
  for f in "$SCRIPT_DIR/claude/internal/"*.md "$SCRIPT_DIR/claude/internal/"*.json; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/internal/$(basename "$f")"
    echo "  copied internal/$(basename "$f")"
  done

  # Scaffold memory templates (skip if destination files already exist)
  MEMORY_DEST="$CLAUDE_DIR/internal/memory"
  mkdir -p "$MEMORY_DEST"
  for template in "$SCRIPT_DIR/claude/internal/memory/"*.md; do
    [ -f "$template" ] || continue
    fname=$(basename "$template")
    if [ ! -f "$MEMORY_DEST/$fname" ]; then
      cp "$template" "$MEMORY_DEST/$fname"
      echo "  scaffolded: internal/memory/$fname"
    else
      echo "  skipped (exists): internal/memory/$fname"
    fi
  done
fi

echo "Done."
