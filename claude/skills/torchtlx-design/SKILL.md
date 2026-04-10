---
name: torchtlx-design
description: Run the TorchTLX design panel. 6 expert agents collaborate to produce
  a design proposal for a TLX feature or change.
---

# TorchTLX Design Panel

You are orchestrating a design review with 6 expert agents. Follow these steps:

## Step 1 — Load context

Read ALL of these files with the Read tool:
- `~/.claude/skills/torchtlx/SKILL.md` (conventions)
- `~/.claude/knowledge/torchtlx/panels/design/constraints.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-tlx-upstream.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-kernel.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-inductor.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-heuristics.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-fusion.md`
- `~/.claude/knowledge/torchtlx/panels/design/agent-hop.md`

## Step 2 — Get the task

If the user didn't provide a task in their message, ask:
> What TLX feature or change do you want to design?

## Step 3 — Sequential agent pass

For each agent in order, adopt that agent's perspective and answer its
"Design Responsibilities" questions. Write each agent's analysis in a section:

1. **TLX Upstream** — reference kernel feasibility, config params needed
2. **Kernel Architect** — hardware constraints, template structure, barriers
3. **Inductor Integration** — compilation pipeline impact, hooks needed
4. **Higher-Order Ops** — subgraph/HOP interaction, decompose_k implications
5. **Heuristics & Autotuning** — config selection rules, shape coverage
6. **Fusion & Epilogue** — fusion compatibility, kernel naming, epilogue handling

Each agent reads prior agents' output. Flag conflicts explicitly
(e.g., "Kernel says feasible but Inductor requires new OSS hook → C1 concern").

## Step 4 — Synthesize

Present a unified design proposal:
- **Summary**: what the feature does
- **Approach**: key implementation decisions
- **Constraints**: which constraints apply (C1, C2) and how they're satisfied
- **Risks**: conflicts or open questions from the agent pass
- **Files to change**: list of files that need modification

Ask the user to approve, modify, or reject the proposal.
