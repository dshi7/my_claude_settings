# TorchTLX Testing — FB-Internal Commands

## Unit Tests

```bash
buck test @mode/opt -c fbcode.platform010_cuda_version=12.8 fbcode//caffe2/test/inductor/fb/tlx:
```

## Test Files

- `fbcode/caffe2/test/inductor/fb/tlx/` — TLX-specific unit tests
- `fbcode/caffe2/test/inductor/test_torchinductor.py` — upstream Inductor tests (run with TLX enabled)

## Debugging

Set env vars before `buck test` for verbose output:
```
TORCH_LOGS="+inductor,+fusion,output_code"
```

## Skip Conditions

Every GPU test requires:
- `has_datacenter_blackwell_tma_device()` — B200 or later with TMA support
- `config.is_fbcode()` — must be in fbsource
- `has_tlx()` — checks `import triton.language.extra.tlx`
