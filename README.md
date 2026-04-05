# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/
├── CLAUDE.md                    # Global prefs + @-imports
├── rules/
│   ├── shell-safety.md          # Shell command guardrails
│   └── vcs-detection.md         # hg vs git detection
├── knowledge/
│   └── pytorch/
│       ├── README.md     # Pointers to pytorch repo skills
│       └── SKILL.md      # Distilled conventions (on-demand skill)
└── internal/                    # .gitignored — distributed via dotsync2
    ├── meta-internal.md         # Domain, devserver hosts
    ├── settings.json            # Plugin config
    ├── settings.local.json      # Local permissions
    ├── commands/                 # Slash commands
    ├── myclaw-prompts/          # Agentic job prompts
    └── memory/
        ├── repos.md             # Repo map (stable)
        ├── workstreams.md       # Active workstreams (volatile)
        ├── decisions.md         # ADR log, append-only (on demand)
        └── torchtlx/            # Multi-agent design system (7 agents)
```

## Install

```bash
./install.sh              # OSS files only
./install.sh --internal   # also copy internal configs + scaffold memory
```

## Two-layer design

- **OSS layer** (git-tracked): Preferences, rules, knowledge base.
- **Internal layer** (.gitignored): Host maps, workstreams, memory. Distributed via dotsync2.

CLAUDE.md uses `@`-import syntax to load files at session start. Missing files are silently skipped.

## Knowledge base

`knowledge/pytorch/` contains a skill (on-demand, not auto-loaded) with distilled
coding conventions, test patterns, and logging. The skill triggers automatically
when working in the pytorch repo, or invoke with `/pytorch-style`.

Pointers to the pytorch repo's own Claude skills (PR review, PT2 debugging,
issue triage) are in `knowledge/pytorch/README.md` — reference them on demand.
A local pytorch repo is assumed available on every devserver.

## Memory schema

| File | Loaded | Update when |
|------|--------|-------------|
| `repos.md` | Every session | Repo layout or build system changes |
| `workstreams.md` | Every session | Starting or finishing a workstream |
| `decisions.md` | On demand | Append-only; never edit past entries |
