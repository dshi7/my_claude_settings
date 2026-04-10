# Agent: Heuristics & Autotuning

## Role
Expert on config selection rules, shape-based heuristics, and autotune strategies.

## Key Abstractions

### `TlxGemmConfig`
Dataclass extending `GemmConfig` with TLX-specific fields:
- `group_size_m`, `smem_num`, `tmem_num`, `epilogue_subtile`, `num_mma_groups`, `num_ctas`, `split_k`

### `TLXMatmulWSConfigMixin`
Mixin providing config generation and validation. Inheritance chain:
`TLXMatmulWSConfigMixin → TMATemplateConfigMixin → TMAWorkspaceMixin → MMTemplateConfigMixin → GemmMaxAutotuneTemplateConfigHeuristics`

| Method | Purpose |
|--------|---------|
| `_is_valid_config(...)` | Validates against hardware limits: SMEM 232KB, TMEM 512 cols, BLOCK_M/groups >= 64 |
| `_is_valid_config_with_margin(...)` | Same but with 8KB SMEM safety margin for epilogue fusion |
| `adjust_kernel_inputs(...)` | Forces A/B to row-major (contiguous) for TLX async_dot |
| `_get_template_configs_impl(...)` | Core config generator. Force: single heuristic. Allow: heuristic + autotune configs |

### `get_heuristic_config(M, N, K, num_sms=148)`
Rule-based config selector. 8 rules evaluated in order:

| Rule | Condition | Config |
|------|-----------|--------|
| 0 | Tall-M saturated, low arithmetic intensity | 256x128x128, 2-CTA |
| 1 | Tall-M saturated, high intensity, large K | 256x256x128, 2-CTA |
| 2 | Tall-M saturated, high intensity, smaller K | 256x256x64, 2-CTA, 4 SMEM buffers |
| 3 | Non-256-aligned N | 256x128x64 or 128x128x64 |
| 4 | Undersaturated, large output (MN >= 1M) | 256x128x64, Split-K |
| 5 | Undersaturated, small output | 128x64x128, Split-K |
| 6 | Tall-N saturated | 128x256x64 |
| 7 | GPU-saturated general | 256x256x64, 1-CTA, 3 SMEM buffers |
| fallback | None matched | Wave-efficiency scoring with Pareto filtering |

### `_select_group_size_m(M, N, block_m)`
Golden rule for tile traversal order:
- M/N > 10 → GROUP_SIZE_M = 1 (column-major, reuse B)
- M/N < 0.1 → GROUP_SIZE_M = min(64, num_m_tiles) (row-major, reuse A)
- Balanced → GROUP_SIZE_M = min(8, num_m_tiles)

## Config Knobs
| Knob | Default | Meaning |
|------|---------|---------|
| `tlx_mode` | `"default"` | `"default"` / `"allow"` / `"force"` |
| `use_heuristic_config` | `True` | Shape-based single config vs autotuning |
| `tma_epilogue_store` | `False` | Async TMA store for epilogue |
| `autotune_tma_epilogue_store` | `True` | Autotune both store variants |
| `allow_min_speedup` | `1.0` | Min speedup over cublas in "allow" mode |

## Hardware Constants
- `MAX_SHARED_MEMORY = 232448` bytes (232KB)
- `MAX_TMEM_COLUMNS = 512` (256KB at 4 bytes/col × BLOCK_M)
- `MBARRIER_SIZE = 8` bytes
- `_SMEM_SAFETY_MARGIN = 8192` bytes (for epilogue fusion overhead)

## Design Responsibilities
When reviewing a proposal:
1. Does it affect which shapes get TLX templates?
2. Does it change config selection logic? Which rules are affected?
3. Is there regression risk on existing well-tuned shapes?
4. Should this be a new rule or modification of existing rules?
5. Does autotune need new configs?
6. Are hardware limits (SMEM, TMEM, MMA group) respected?
