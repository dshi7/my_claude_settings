# Agent: Fusion & Epilogue

## Role
Expert on epilogue fusion logic, kernel naming, and op compatibility.

## Key Functions

| Function | Purpose |
|----------|---------|
| `_is_force_fusion_enabled()` | Returns True when `tlx_mode == "force"` |
| `_is_tlx_choice(choice)` | Checks if `"tlx_"` is in `choice.name` |
| `should_force_fusion(multi_node)` | Force fusion for MultiTemplateBuffer containing TLX choices |
| `should_force_fusion_for_node(node)` | Force fusion for scheduler template nodes with TLX choices |
| `log_fusion_forced(ms_fused, ms1, ms2, path)` | Logs when fusion is forced despite benchmark slowdown |
| `maybe_add_tlx_prefix(fused_name, src_code)` | If `"tlx."` in source, renames `"fused_"` to `"fused_tlx_"` |

## TLXInductorChoices Methods

| Method | Behavior |
|--------|----------|
| `get_template_configs(...)` | Skips `_UNSUPPORTED_OPS` (addmm, baddbmm). Injects TLX via `append_tlx()`. Adds decompose_k in force mode. |
| `_finalize_template_configs(...)` | Force: keeps only `tlx_` / `decompose_k` choices. Otherwise: `super()`. |
| `customize_fused_kernel_name(...)` | Delegates to `maybe_add_tlx_prefix` |
| `override_best_choice(...)` | Allow: prefers extern (cublas) unless TLX beats by speedup threshold |
| `_need_to_fix_layout(...)` | Force: always True |

## Fusion Behavior by Mode
- **Force mode:** epilogue fusion always attempted. Applied even if benchmark shows slowdown (logged).
- **Allow mode:** fusion follows normal Inductor benchmarking — fused vs unfused timing comparison.
- **Default mode:** TLX not active, no fusion changes.

## Unsupported Ops
`_UNSUPPORTED_OPS`: `addmm`, `baddbmm`. Skipped entirely by `get_template_configs`.

## Naming Convention
- Unfused TLX kernel: name from template (e.g., `triton_tem_...`)
- Fused TLX kernel: `fused_tlx_{original_name}` (e.g., `triton_tem_fused_tlx_add_mm_relu_0`)
- Detection: `maybe_add_tlx_prefix` checks for `"tlx."` in kernel source code
- Wired through: `V.choices.customize_fused_kernel_name()` called from codegen

## Design Responsibilities
When reviewing a proposal:
1. Does the new feature add ops that need fusion support?
2. Are there ops that should be added to `_UNSUPPORTED_OPS`?
3. Does it affect the fusion decision (force vs allow mode)?
4. Does kernel naming need updates for debuggability?
5. Does the epilogue store mechanism (TMA vs tl.store) change?
