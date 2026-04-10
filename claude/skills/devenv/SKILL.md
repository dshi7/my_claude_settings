---
name: devenv
description: Audit and fix local dev environment — nvim, hg/sl, git, tmux, toolchain, certs.
---

# Dev Environment Check

Run the checks below in order. For each section, report PASS or FAIL with details.
After all checks, summarize and offer to fix any failures.

## 1. Neovim

Run these commands and report results:

```bash
# Config loads without errors
nvim --headless -c 'qall' 2>&1

# Lazy.nvim plugin check
nvim --headless -c 'Lazy check' -c 'qall' 2>&1

# Health check (save to temp file)
nvim --headless -c 'checkhealth' -c 'w! /tmp/nvim-health.txt' -c 'qall' 2>&1
```

Check these paths exist:
- `~/.config/nvim/init.lua`
- `~/.config/nvim/lua/plugins/`
- `~/.local/share/nvim/lazy/` (lazy.nvim plugin dir)

**Fix if broken:**
```bash
nvim --headless -c 'Lazy install' -c 'qall'
nvim --headless -c 'Lazy sync' -c 'qall'
nvim --headless -c 'TSUpdateSync' -c 'qall'
```

## 2. Sapling / Mercurial

Check binary: `which sl` and `sl --version`

Check these aliases exist in `~/.bashrc`:
- `hgb`, `hgs`, `hgp`, `hgu` — basic navigation
- `hgdc` (`sl vdiff -c .`) — diff committed changes
- `hgdu` (`sl vdiff`) — diff uncommitted changes
- `hgda` (`sl vdiff -r .^`) — diff against parent
- `hgsl`, `hgdiff`, `hgvimdiff` — log and diff

Report any missing aliases.

## 3. Git

Check binary: `which git` and `git --version`

Check these aliases exist in `~/.bashrc`:
- `gs`, `ga`, `gbv`, `ghrev` — status, add, branch
- `gdc` (`git difftool HEAD~1 HEAD`) — diff committed
- `gdu` (`git difftool`) — diff uncommitted
- `gda` (`git difftool HEAD~1`) — diff against parent
- `gri`, `grc` — rebase interactive, continue

Report any missing aliases.

## 4. tmux

Check binary: `which tmux` and `tmux -V`
Check config: `~/.tmux.conf` exists

## 5. Toolchain

Check these are on PATH and working:
- `gcc-13`: `gcc --version` (expect 13.x from `/data/users/$USER/gcc-13/bin`)
- `nvcc`: `nvcc --version` (expect CUDA 12.6+ from `$CUDA_HOME`)
- `conda`: `conda --version`
- `python3`: `python3 --version`

Check env vars are set:
- `CUDA_HOME` — should point to `/usr/local/cuda-12.x`
- `CUDACXX` — should be `$CUDA_HOME/bin/nvcc`
- `TRITON_CACHE_DIR` — should be `/tmp/triton_cache_$USER`

## 6. Certificates

```bash
klist -s 2>/dev/null
```

If expired, suggest: `renew_certificate` (alias for `kdestroy && kinit && fbwallet_fetch`)

## Summary

Present results as a table:

| Check | Status | Details |
|-------|--------|---------|
| nvim config | PASS/FAIL | ... |
| nvim plugins | PASS/FAIL | ... |
| sl/hg | PASS/FAIL | ... |
| hg aliases | PASS/FAIL | N missing |
| git | PASS/FAIL | ... |
| git aliases | PASS/FAIL | N missing |
| tmux | PASS/FAIL | ... |
| gcc-13 | PASS/FAIL | ... |
| nvcc/CUDA | PASS/FAIL | ... |
| conda | PASS/FAIL | ... |
| certs | PASS/FAIL | ... |

Then ask: "Fix N issues? (list what will be done)"

For nvim plugin issues, run the Lazy install/sync commands.
For missing aliases, show the missing alias lines but do NOT edit ~/.bashrc
without confirmation.
For expired certs, suggest the user run `! renew_certificate`.
For missing toolchain, report only — these require manual install.
