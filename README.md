# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/                              # OSS layer — git-tracked, refreshed each install
├── CLAUDE.md                        # Global prefs + @-imports to internal/
├── settings.json                    # Hooks wiring (PreToolUse, SessionStart, etc.)
├── rules/
│   ├── shell-safety.md              # Shell command guardrails
│   └── kernel-style.md              # GPU kernel conventions (path-scoped)
├── hooks/
│   ├── vcs-guard.sh                 # Block wrong VCS commands (PreToolUse)
│   ├── commit-guard.sh              # Block commit/amend/submit (PreToolUse)
│   ├── danger-guard.sh              # Block destructive commands (PreToolUse)
│   ├── session-start.sh             # Inject hostname + GPU type (SessionStart)
│   ├── cwd-changed.sh               # Set REPO_VCS env var (CwdChanged)
│   ├── post-compact.sh              # Persist summary to workstreams.md (PostCompact)
│   └── instructions-loaded.sh       # Debug logging (InstructionsLoaded)
└── knowledge/                       # Distilled OSS-safe project knowledge
    ├── pytorch/                     # PyTorch conventions (/pytorch-style)
    ├── torchtlx/                    # TLX conventions (/torchtlx-style)
    ├── fbtriton-ci/                 # CI workflow conventions (/fbtriton-ci)
    └── triton-tbe/                  # TBE kernel conventions (/triton-tbe)

templates/internal/                  # Seeds for internal layer (one-time scaffold)
├── fb-internal.md                   # Domain, devserver hosts, repo paths
├── torchtlx.md                      # FB-internal TLX context
├── fbtriton-ci.md                   # FB-internal CI tools context
├── triton-tbe.md                    # FB-internal TBE benchmarks context
└── memory/
    ├── repos.md                     # Repo map
    ├── workstreams.md               # Active workstreams (appended by post-compact hook)
    └── decisions.md                 # ADR log, append-only
```

## Two-layer design

```
Git Repo (OSS)                          ~/.claude/internal/ (dotsync2)
─────────────────                       ─────────────────────────────
claude/          ──install.sh──►        OSS files (refreshed each run)
templates/internal/ ──scaffold──►       internal/ (seeded once, edit in place)
                                              │
                                        dotsync2 sync
                                              │
                                   ┌──────────┼──────────┐
                                   ▼          ▼          ▼
                              devgpu006  devgpu031  devgpu035 ...
```

- **OSS layer** (`claude/`): Preferences, rules, hooks, knowledge. Git-tracked,
  refreshed on every `install.sh` run. Polishable by external agents.
- **Internal layer** (`templates/internal/`): FB-only context. Scaffolded once
  by `install.sh --internal` — if the file already exists, it's skipped.
  After first install, **edit `~/.claude/internal/` directly** on any devgpu.
  dotsync2 syncs changes across all devservers.

CLAUDE.md uses `@`-imports to load internal files at session start.
Missing files are silently skipped.

## Install

```bash
./install.sh              # OSS files only (rules, hooks, skills, settings)
./install.sh --internal   # also scaffold internal context + memory
```

**Requires `jq`** — install.sh deep-merges hooks from the repo into your
existing `~/.claude/settings.json`, preserving `enabledPlugins`, `env`, and
other live keys. Without jq, it falls back to a plain copy.

Safe to re-run: OSS files are always updated, internal files are never
overwritten (skip-if-exists).

### What `install.sh --internal` does

| Action | Files | Effect |
|--------|-------|--------|
| **Overwrite** | `CLAUDE.md` | Lean version with prefs + @-imports |
| **Overwrite** | `rules/*.md` | Shell safety, kernel style |
| **Merge** | `settings.json` | Adds hooks, preserves `enabledPlugins` and `env` |
| **Overwrite** | `skills/` (from `knowledge/`) | OSS skills: pytorch, torchtlx, fbtriton-ci, triton-tbe, debug-tlparse |
| **Copy** | `hooks/*.sh` | 7 lifecycle hook scripts |
| **Copy** | `knowledge/*/README.md` | Knowledge base READMEs |
| **Scaffold** | `internal/*.md` | FB-internal context (skip-if-exists) |
| **Scaffold** | `internal/memory/*.md` | Memory templates (skip-if-exists) |
| **Scaffold** | `skills/triton-ci-status/` | Internal skill (skip-if-exists) |

**Not touched**: `settings.local.json`, `projects/` (auto-memory), `history.jsonl`,
`commands/`, runtime state (`backups/`, `debug/`, `meta/`, `sessions/`).

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `vcs-guard.sh` | PreToolUse (Bash) | Blocks `hg` in git repos and `git` in hg repos |
| `commit-guard.sh` | PreToolUse (Bash) | Blocks commit, amend, force-push, and jf submit |
| `danger-guard.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, `git reset --hard`, rebase without `-d` |
| `session-start.sh` | SessionStart | Injects devserver hostname and GPU type into context |
| `cwd-changed.sh` | CwdChanged | Sets `REPO_VCS=hg|git|none` env var |
| `post-compact.sh` | PostCompact | Appends compact summary to `workstreams.md` |
| `instructions-loaded.sh` | InstructionsLoaded | Logs loaded files to `~/.claude/logs/` |

### Testing hooks

```bash
# Should deny:
echo '{"tool_input":{"command":"sl commit -m test"},"cwd":"/tmp"}' | bash claude/hooks/commit-guard.sh

# Should deny:
echo '{"tool_input":{"command":"git reset --hard HEAD~3"},"cwd":"/tmp"}' | bash claude/hooks/danger-guard.sh

# Should pass (no output):
echo '{"tool_input":{"command":"sl diff"},"cwd":"/tmp"}' | bash claude/hooks/commit-guard.sh
```

## Knowledge base

Each project under `knowledge/` has:
- `SKILL.md` — distilled conventions, installed as an on-demand skill
- `README.md` — overview and pointers to the upstream repo's own Claude skills

| Project | Skill | Based on |
|---------|-------|----------|
| pytorch | `/pytorch-style` | pytorch/pytorch |
| torchtlx | `/torchtlx-style` | pytorch/pytorch + facebookexperimental/triton |
| fbtriton-ci | `/fbtriton-ci` | facebookexperimental/triton CI |
| triton-tbe | `/triton-tbe` | pytorch/FBGEMM + facebookexperimental/triton |
| debug-tlparse | `/debug-tlparse` | OSS tlparse (fbcode//caffe2/fb/tlparse) |

## Memory schema

| File | Loaded | Update when |
|------|--------|-------------|
| `repos.md` | Every session | Repo layout or build system changes |
| `workstreams.md` | Every session | Starting or finishing a workstream |
| `decisions.md` | On demand | Append-only; never edit past entries |
