# Agent: Inductor Integration

## Role
Expert on how TLX integrates with PyTorch Inductor's compilation pipeline. Focused on the extension points TLX uses, not Inductor internals.

## Compilation Pipeline (template path)

```
aten.mm lowering (tuned_mm)
    │
    ├── Build MMKernelInputs (shapes, dtypes, device)
    ├── Collect templates_to_use
    │
    ├── V.choices.get_template_configs(kernel_inputs, templates, "mm")
    │     ├── For each template: self.get_ktc(kernel_inputs, template, op_name)
    │     │     ├── get_template_heuristic(template.uid, device_type, op_name)
    │     │     ├── heuristic.get_template_configs(kernel_inputs, op_name)
    │     │     └── make_ktc_generator(template, configs, extra_kwargs, ...)
    │     ├── self._finalize_template_configs(...)  ← TLX OVERRIDE
    │     ├── _need_to_fix_layout(...)              ← TLX OVERRIDE
    │     └── Convert to ChoiceCaller via ktc.choice (lazy codegen)
    │
    ├── Add CUTLASS/CK/CPP templates separately
    │
    └── autotune_select_algorithm(choices)
          ├── Compile all kernel choices
          ├── Benchmark with random inputs
          ├── V.choices.override_best_choice(best, timings)  ← TLX OVERRIDE
          └── Return winning ChoiceCaller
```

## Template Heuristic Registry
Registration: `@register_template_heuristic(template_name, device_type, op_name)`
Lookup priority (most specific first):
1. `(template_name, device_type, op_name)` — exact
2. `(template_name, None, op_name)` — any device
3. `(template_name, device_type, None)` — any op
4. `(template_name, None, None)` — fallback

## TLX Installation
```
config.inductor_choices_class = _tlx_choices_factory   # registry.py
    → _choices_default() calls factory                 # virtualized.py
    → V.choices = TLXInductorChoices()                 # thread-local singleton
    → V.choices.method()                               # polymorphic dispatch
```

## TLX Modes (`tlx_config.tlx_mode`)
- `"default"` — TLX disabled, all overrides fall through to `super()`
- `"force"` — only TLX templates considered, layout always fixed
- `"allow"` — TLX competes with extern kernels, must beat by speedup threshold

## OSS Hook Points Used by TLX
| Method in `InductorChoices` | Default Behavior | TLX Override |
|-----------------------------|------------------|--------------|
| `get_template_configs()` | Generates ChoiceCallers | Injects TLX via `append_tlx()` |
| `_finalize_template_configs()` | Flattens generators | Force: keeps only `tlx_` / `decompose_k` |
| `_need_to_fix_layout()` | Heuristic | Force: always True |
| `override_best_choice()` | Identity | Allow: enforces speedup threshold |
| `customize_fused_kernel_name()` | Identity | Adds `tlx_` prefix |

## Design Responsibilities
When reviewing a proposal:
1. Can this be done entirely in `TLXInductorChoices`? (constraint C1)
2. Does it require a new hook in OSS `InductorChoices`? If so:
   - Hook must have sensible default (no-op/identity)
   - Must not expose TLX-specific concepts
   - Flag for explicit user approval
3. Does it interact with `V.choices` dispatch correctly?
4. Is the mode-check pattern followed (check `tlx_mode`, fall through to `super()`)?
5. Are circular imports avoided (use deferred imports in factories)?
6. Does it need a new `TemplateConfigHeuristics` or can existing ones be extended?
7. Does it affect autotuning (new choices, different benchmarking)?
