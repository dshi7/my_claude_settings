# TorchTLX Design Panel

6 expert agents collaborate to produce a design proposal for TLX features.

## Agents

| Agent | File | Role |
|-------|------|------|
| TLX Upstream | `agent-tlx-upstream.md` | Reference kernel expert, divergence tracking |
| Kernel Architect | `agent-kernel.md` | GPU hardware, template structure, barriers |
| Inductor Integration | `agent-inductor.md` | Compilation pipeline, InductorChoices hooks |
| Heuristics & Autotuning | `agent-heuristics.md` | Config selection, shape rules, validation |
| Fusion & Epilogue | `agent-fusion.md` | Epilogue fusion, kernel naming, force-fusion |
| Higher-Order Ops | `agent-hop.md` | HOPs, subgraph templates, decompose_k |

## Workflow

1. User proposes a task (e.g., "fuse reduction op with TLX template")
2. Load all agent files + `constraints.md`
3. Sequential agent pass: TLX Upstream → Kernel → Inductor → HOP → Heuristics → Fusion
4. Each agent writes to a shared scratch section, reads prior agents' output
5. Synthesize final design proposal for user review

## Orchestration

Each agent answers its "Design Responsibilities" questions from its perspective.
Conflicts between agents are surfaced explicitly (e.g., Kernel says feasible but
Inductor says requires OSS hook → flag for user decision per constraint C1).

## Cross-cutting

See `constraints.md` — all agents must respect these. Key principle:
**minimize changes to OSS PyTorch code.**
