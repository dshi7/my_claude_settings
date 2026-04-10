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

# Install skills from knowledge directories
# Each directory containing a SKILL.md is installed to ~/.claude/skills/<dirname>/
for skill_file in "$SCRIPT_DIR/claude/knowledge/"*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  dest="$CLAUDE_DIR/skills/$skill_name"
  mkdir -p "$dest"
  cp "$skill_file" "$dest/SKILL.md"
  echo "  installed skill: $skill_name"
done

# Copy non-skill knowledge files (README.md, etc.)
for dir in "$SCRIPT_DIR/claude/knowledge/"*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  dest="$CLAUDE_DIR/knowledge/$name"
  mkdir -p "$dest"
  for f in "$dir"*; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    [ "$fname" = "SKILL.md" ] && continue  # already installed as skill
    cp "$f" "$dest/$fname"
    echo "  copied knowledge/$name/$fname"
  done
done

# Copy hooks
if [ -d "$SCRIPT_DIR/claude/hooks" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  for f in "$SCRIPT_DIR/claude/hooks/"*.sh; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
    chmod +x "$CLAUDE_DIR/hooks/$(basename "$f")"
    echo "  copied hooks/$(basename "$f")"
  done
fi

# Merge settings.json (deep-merge repo hooks into existing, preserving plugins/env)
if [ -f "$SCRIPT_DIR/claude/settings.json" ]; then
  if [ -f "$CLAUDE_DIR/settings.json" ] && command -v jq &>/dev/null; then
    jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" "$SCRIPT_DIR/claude/settings.json" \
      > "$CLAUDE_DIR/settings.json.tmp"
    mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
    echo "  merged settings.json (preserved existing keys)"
  else
    cp "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  copied settings.json (fresh install)"
  fi
fi

# Optionally install internal (FB-only) files from templates/
# Templates are git-tracked; installed to ~/.claude/internal/ (synced by dotsync2).
if [ "${1:-}" = "--internal" ] && [ -d "$SCRIPT_DIR/templates/internal" ]; then
  mkdir -p "$CLAUDE_DIR/internal"

  # Scaffold all internal files (skip if destination already exists)
  # Live copy in ~/.claude/internal/ is canonical — edit there, dotsync2 syncs.
  # Templates are just initial seeds.
  for f in "$SCRIPT_DIR/templates/internal/"*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    if [ ! -f "$CLAUDE_DIR/internal/$fname" ]; then
      cp "$f" "$CLAUDE_DIR/internal/$fname"
      echo "  scaffolded: internal/$fname"
    else
      echo "  skipped (exists): internal/$fname"
    fi
  done

  MEMORY_DEST="$CLAUDE_DIR/internal/memory"
  mkdir -p "$MEMORY_DEST"
  for template in "$SCRIPT_DIR/templates/internal/memory/"*.md; do
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
