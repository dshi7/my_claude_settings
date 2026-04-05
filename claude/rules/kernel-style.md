---
path_scope: "**/triton/**,**/inductor/**,**/kernels/**"
---

# GPU Kernel Conventions

When writing or reviewing GPU kernel code (Triton, CUDA, or Inductor-generated):

## Performance

- Prefer `tl.load` / `tl.store` with explicit masks over branching.
- Tile sizes must be powers of two.
- Minimize shared memory bank conflicts — pad shared arrays to avoid stride collisions.
- Avoid Python-level loops that should be GPU-level loops. Every `for` in a Triton kernel is unrolled at compile time — keep trip counts small.

## Correctness

- Always specify `dtype` explicitly in `tl.zeros`, `tl.full`, and casts. Never rely on implicit promotion.
- Check that reduction dimensions match between the kernel launch grid and the kernel body.
- For atomic operations, verify memory ordering requirements.

## Style

- Name kernel functions with a `_kernel` suffix (e.g., `matmul_kernel`).
- Keep autotune configs in a list above the kernel, not inline.
- Use `BLOCK_M`, `BLOCK_N`, `BLOCK_K` naming for tile dimensions.
- Add a one-line docstring stating the operation (e.g., `"""Fused add + layernorm kernel."""`).

## Testing

- Every new kernel needs a reference implementation test comparing against PyTorch eager.
- Use `torch.testing.assert_close` with appropriate `atol`/`rtol` for the dtype.
- Test at least two shapes: a "nice" power-of-two shape and an edge case with remainder tiles.
