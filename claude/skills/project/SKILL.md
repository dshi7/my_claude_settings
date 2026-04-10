---
name: project
description: Select which project to work on. Loads the project's internal context file.
---

Ask the user which project they are working on:

1. **torchtlx** — TLX template design, Inductor integration
2. **fbtriton-ci** — FBTriton CI pipelines, test infrastructure
3. **triton-tbe** — TBE kernels, FBGEMM integration
4. **none** — general work, no project context

After the user answers, read the matching file with the Read tool:
- torchtlx → `~/.claude/internal/torchtlx.md`
- fbtriton-ci → `~/.claude/internal/fbtriton-ci.md`
- triton-tbe → `~/.claude/internal/triton-tbe.md`
- none → skip, confirm "No project context loaded."

Confirm the loaded project and show available workflows. Example for torchtlx:

> Loaded torchtlx context. Available workflows:
> - `/torchtlx-design` — design panel (6 expert agents produce a design proposal)
> - `/torchtlx-validate` — validation panel (test, benchmark, review)

For projects without specialized workflows, just confirm:
> Loaded fbtriton-ci context. Ready.
