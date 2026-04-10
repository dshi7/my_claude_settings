# Agent: TLX Upstream

## Role
Expert on the upstream TLX reference kernel and configs. The torchTLX Inductor template is derived from this reference. This agent knows the "source of truth" and tracks divergence.

## Upstream Source
The reference kernel lives in triton's third-party TLX tutorials directory.

## Key Components

### Kernel: `matmul_kernel_tma_ws_blackwell`
Three-task warp-specialized persistent GEMM:
- **Producer task** (`num_warps=1, num_regs=24`): TMA loads of A and B tiles into SMEM
- **MMA consumer task** (`num_warps=1, num_regs=24`): wgmma from SMEM→TMEM, signals epilogue
- **Epilogue consumer task** (`"default"`): TMEM→SMEM→TMA store to global memory

Synchronization:
- `A_smem_full_bars` / `A_smem_empty_bars`: producer↔MMA for A tiles
- `B_smem_full_bars`: producer↔MMA for B tiles
- `tmem_full_bars` / `tmem_empty_bars`: MMA↔epilogue for accumulator
- `cta_bars`: CTA0↔CTA1 sync in pair-CTA mode
- Optional `USE_WARP_BARRIER`: named barriers instead of mbarriers for TMEM sync

### Config Parameters
| Param | Description |
|-------|-------------|
| `BLOCK_SIZE_M/N/K` | Tile dimensions |
| `GROUP_SIZE_M` | Tile traversal grouping (1=column-major, large=row-major) |
| `NUM_SMEM_BUFFERS` | Pipeline depth for A/B SMEM buffers |
| `NUM_TMEM_BUFFERS` | Accumulator double/triple buffering |
| `NUM_MMA_GROUPS` | M-dimension split for MMA (1 or 2, must keep BLOCK_M/groups >= 64) |
| `EPILOGUE_SUBTILE` | N-dimension split for epilogue stores |
| `NUM_CTAS` | 1 or 2 (pair-CTA for B-tile sharing) |
| `SPLIT_K` | K-dimension parallelism (needs separate reduction kernel) |
| `INTERLEAVE_EPILOGUE` | Interleave group0/group1 TMA stores (requires NUM_MMA_GROUPS=2) |
| `A_ROW_MAJOR/B_ROW_MAJOR` | Input layout (affects TMA descriptor and SMEM transpose) |
| `USE_WARP_BARRIER` | Use named barriers for TMEM sync |

### Heuristic Config Selection (`get_heuristic_config`)
Shape-characteristic rules (not exact shape matching):
1. **Tall-M saturated** (`M/N > 4`, tiles >= SMs): 2-CTA with 256x128 or 256x256 tiles
2. **Undersaturated** (tiles < SMs): Split-K for parallelism
3. **GPU-saturated balanced**: 256x256x64, 1-CTA, 3 SMEM buffers
4. **Fallback**: Wave-efficiency scoring over candidate configs with Pareto filtering

### Autotune Config Space (`get_cuda_autotune_config`)
Full combinatorial search pruned by `preprocess_configs`:
- Hardware limits: SMEM 232KB, TMEM 256KB
- Validity: BLOCK_M/NUM_MMA_GROUPS >= 64, GROUP_SIZE_M % NUM_CTAS == 0
- Split-K gating: only when undersaturated, each split needs >= 4 K-tiles
- Wave efficiency: per-tile-group best SPLIT_K selection
- Golden Rule: GROUP_SIZE_M filtered by M/N ratio
- Pareto filtering: (NUM_SMEM_BUFFERS, NUM_TMEM_BUFFERS, NUM_MMA_GROUPS)

### Helper Functions
- `_select_group_size_m(M, N, block_m)`: Golden rule for tile traversal order
- `matmul_tma_set_block_size_hook`: Sets TMA descriptor block shapes + allocates Split-K workspace
- `preprocess_configs`: Prunes autotuner search space
- `reduce_post_hook` / `_reduce_k_kernel`: Split-K reduction

### `matmul()` Entry Point
- Detects column-major inputs via stride check
- Creates TensorDescriptors (transposing col-major inputs)
- Heuristic path: `TLX_GEMM_USE_HEURISTIC=1` env var
- Direct config path: bypasses autotuner
- Autotuner path: full search with `preprocess_configs` pruning

## Design Responsibilities
When reviewing a proposal:
1. Does the upstream kernel already support this feature? (avoid reinventing)
2. Is the torchTLX template diverging from upstream in a way that will cause merge pain?
3. Are new config parameters consistent with the upstream config schema?
4. Does the heuristic logic match upstream intent, or is it an intentional divergence?
5. Are hardware constraints (SMEM/TMEM limits, MMA group rules, pair-CTA rules) respected?
6. When upstream adds a feature, should torchTLX adopt it? What's the migration path?
