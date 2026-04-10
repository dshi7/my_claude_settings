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
├── skills/
│   ├── project/                     # /project — select project, load context
│   ├── torchtlx-design/             # /torchtlx-design — design panel
│   └── torchtlx-validate/           # /torchtlx-validate — validation panel
└── knowledge/                       # Distilled OSS-safe project knowledge
    ├── pytorch/                     # PyTorch conventions (/pytorch-style)
    ├── torchtlx/                    # TLX conventions (/torchtlx-style)
    │   ├── panels/design/           #   Design panel (6 expert agents)
    │   └── panels/validation/       #   Validation panel (3 agents)
    ├── fbtriton-ci/                 # CI workflow conventions (/fbtriton-ci)
    └── triton-tbe/                  # TBE kernel conventions (/triton-tbe)

templates/internal/                  # Seeds for internal layer (one-time scaffold)
├── fb-internal.md                   # Domain, devserver hosts, repo paths
├── torchtlx.md                      # FB-internal TLX context
├── torchtlx-testing.md              # FB-internal TLX test commands
├── torchtlx-bench.md                # FB-internal EMS benchmark commands + baselines
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

### `install.sh` vs `install.sh --internal`

|  | `./install.sh` | `./install.sh --internal` |
|---|---|---|
| CLAUDE.md | overwrite | overwrite |
| rules/*.md | overwrite | overwrite |
| settings.json | merge | merge |
| hooks/*.sh | overwrite | overwrite |
| skills/ | overwrite | overwrite |
| knowledge/ (incl. panels) | overwrite | overwrite |
| **internal/*.md** | **skip** | **scaffold (skip-if-exists)** |
| **internal/memory/*.md** | **skip** | **scaffold (skip-if-exists)** |
| **internal skills** (triton-ci-status) | **skip** | **scaffold (skip-if-exists)** |

Use `--internal` on first setup or when new internal templates are added.
After that, plain `./install.sh` is enough for updates.

**Not touched**: `settings.local.json`, `projects/` (auto-memory), `history.jsonl`,
`commands/`, runtime state (`backups/`, `debug/`, `meta/`, `sessions/`).

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `vcs-guard.sh` | PreToolUse (Bash) | Blocks `hg` in git repos and `git` in hg repos |
| `commit-guard.sh` | PreToolUse (Bash) | Blocks commit, amend, force-push, and jf submit |
| `danger-guard.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, `git reset --hard`, rebase without `-d` |
| `session-start.sh` | SessionStart | Injects hostname + GPU; re-injects project context after compaction |
| `cwd-changed.sh` | CwdChanged | Sets `REPO_VCS=hg|git|none` env var |
| `post-compact.sh` | PostCompact | Appends summary to `workstreams.md`; persists active project |
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

## Session flow

All project context is lazy-loaded on demand — nothing is eagerly loaded at
session start except host context (`fb-internal.md`) and memory files.

```
Session start (fbsource/fbcode)
        │
        ▼
   /project               ← select project, loads general context
        │
        ├─ <project>
        │   ├─ reads ~/.claude/internal/<project>.md
        │   └─ shows available workflows (if any):
        │       ├─ /<project>-design    ← expert agents → design proposal
        │       └─ /<project>-validate  ← test + bench + review
        │
        └─ none
            └─ no project context loaded
```

Each workflow skill loads its own panel files + internal commands on demand:

| Skill | Loads (git) | Loads (internal) |
|-------|-------------|------------------|
| `/<project>-design` | agent role files + constraints | — |
| `/<project>-validate` | agent role files | internal test/bench commands |

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

### TorchTLX Agent Panels

TorchTLX has two agent panels for collaborative design and automated validation:

**Design panel** (`knowledge/torchtlx/panels/design/`) — 6 expert agents collaborate
sequentially to produce a design proposal for TLX features.

| Agent | File | Role |
|-------|------|------|
| TLX Upstream | `agent-tlx-upstream.md` | Reference kernel expert, divergence tracking |
| Kernel Architect | `agent-kernel.md` | GPU hardware, template structure, barriers |
| Inductor Integration | `agent-inductor.md` | Compilation pipeline, InductorChoices hooks |
| Heuristics & Autotuning | `agent-heuristics.md` | Config selection, shape rules, validation |
| Fusion & Epilogue | `agent-fusion.md` | Epilogue fusion, kernel naming, force-fusion |
| Higher-Order Ops | `agent-hop.md` | HOPs, subgraph templates, decompose_k |

**Validation panel** (`knowledge/torchtlx/panels/validation/`) — 3 agents test,
benchmark, and review a TLX implementation.

| Agent | File | Role | Internal context |
|-------|------|------|-----------------|
| Test Runner | `agent-test.md` | Run unit tests, interpret results | `torchtlx-testing.md` |
| Benchmark Runner | `agent-bench.md` | Run EMS benchmarks, compare MFU | `torchtlx-bench.md` |
| Code Reviewer | `agent-review.md` | Style, xplat sync, constraint compliance | `torchtlx.md` |

## Memory schema

| File | Loaded | Update when |
|------|--------|-------------|
| `repos.md` | Every session | Repo layout or build system changes |
| `workstreams.md` | Every session | Starting or finishing a workstream |
| `decisions.md` | On demand | Append-only; never edit past entries |
