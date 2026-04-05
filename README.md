# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/
├── CLAUDE.md              # General preferences (loaded as ~/.claude/CLAUDE.md)
├── rules/
│   └── shell-safety.md    # Shell command guardrails
└── internal/              # .gitignored — host/project-specific configs
```

## Install

Copy settings into `~/.claude/`:

```bash
./install.sh
```

The script copies `claude/CLAUDE.md` and `claude/rules/*` into `~/.claude/`. Internal files under `claude/internal/` are not copied — manage those separately.

## Two-layer design

- **This repo** holds general, portable settings (preferences, shell safety rules).
- **Internal configs** (host maps, project-specific rules, memory files) live in `claude/internal/` (.gitignored) and are distributed separately (e.g., via dotsync2).
