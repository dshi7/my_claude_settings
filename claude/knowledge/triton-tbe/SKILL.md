---
name: triton-tbe
description: Use when working on Triton TBE (Table Batched Embedding) kernels.
  Covers TBE kernel design, embedding table patterns, performance tuning,
  and testing against PyTorch FBGEMM baselines.
---

# Triton TBE Conventions

<!-- TODO: Distill from TBE working knowledge.
     This is a scaffold — fill in as patterns solidify. -->

## Architecture

- TBE kernels replace FBGEMM CUDA kernels (pytorch/FBGEMM) with Triton implementations
- Triton compiler from facebookexperimental/triton
- Must match FBGEMM numerics and performance targets

## Kernel Patterns

- Follow GPU kernel conventions (see `kernel-style.md` rule)
- Tile over embedding tables, not individual lookups
- Handle variable-length bags and weighted embeddings

## Performance

- Benchmark against FBGEMM baseline at production shapes
- Profile memory bandwidth utilization — TBE is memory-bound
- Test across multiple GPU architectures (H100, B200, GB200)

## Testing

- Compare against `torch.nn.EmbeddingBag` eager reference
- Test edge cases: empty bags, single-element bags, max pooling mode
- Validate gradient correctness for training kernels
