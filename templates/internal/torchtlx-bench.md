# TorchTLX Benchmarks — FB-Internal Commands

## EMS Benchmarks (Efficient Module Suite)

Four modules benchmarked in parallel on separate GPUs. Compare ref vs TLX MFU.

### Common buck flags
```
@mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a
```

### Common benchmark args
```
benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --provider omnifm_all
```

### TLX env vars
```
TORCHINDUCTOR_TLX_MODE=allow
TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1
```

### Module matrix

| Module | mfu_profile_module | Ref GPU | TLX GPU |
|--------|-------------------|---------|---------|
| emb_preproc | domain_experts.shared.user_embedding_arch_preproc | 0 | 1 |
| seq_sum | domain_experts.shared.uniarch.uniarch_layers.0.seq_summarization_layer | 2 | 3 |
| seq_inter | domain_experts.shared.uniarch.uniarch_layers.0.seq_interaction_layer | 4 | 5 |
| nonseq_sum | domain_experts.shared.uniarch.uniarch_layers.0.non_seq_interaction_module | 6 | 7 |

### Ref runs (all 4 in parallel)
```bash
CUDA_VISIBLE_DEVICES=0 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.user_embedding_arch_preproc --provider omnifm_all 2>&1 | tee ~/debug_emb_preproc_ref.log

CUDA_VISIBLE_DEVICES=2 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.seq_summarization_layer --provider omnifm_all 2>&1 | tee ~/debug_seq_sum_ref.log

CUDA_VISIBLE_DEVICES=4 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.seq_interaction_layer --provider omnifm_all 2>&1 | tee ~/debug_seq_inter_ref.log

CUDA_VISIBLE_DEVICES=6 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.non_seq_interaction_module --provider omnifm_all 2>&1 | tee ~/debug_nonseq_sum_ref.log
```

### TLX runs (all 4 in parallel)
```bash
TORCHINDUCTOR_TLX_MODE=allow TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1 CUDA_VISIBLE_DEVICES=1 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.user_embedding_arch_preproc --provider omnifm_all 2>&1 | tee ~/debug_emb_preproc.log

TORCHINDUCTOR_TLX_MODE=allow TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1 CUDA_VISIBLE_DEVICES=3 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.seq_summarization_layer --provider omnifm_all 2>&1 | tee ~/debug_seq_sum.log

TORCHINDUCTOR_TLX_MODE=allow TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1 CUDA_VISIBLE_DEVICES=5 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.seq_interaction_layer --provider omnifm_all 2>&1 | tee ~/debug_seq_inter.log

TORCHINDUCTOR_TLX_MODE=allow TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1 CUDA_VISIBLE_DEVICES=7 buck run @mode/opt -c fbcode.platform010_cuda_version=12.8 -c hpc_comms.use_nccl=2.25.1 -m ovr_config//triton:beta -c fbcode.nvcc_arch=b200a //efficient_module_suite/benchmark:omnifm_perf_benchmark -- benchmark-with-prod-model --prod_config mast_omnifm_v4_2kb200 --prod_config_override prod_config_override_jointarch --batch_size 1152 --enable_pt2 True --mfu_profile_module domain_experts.shared.uniarch.uniarch_layers.0.non_seq_interaction_module --provider omnifm_all 2>&1 | tee ~/debug_nonseq_sum.log
```

## Trunk Baseline MFU (2026-03-17, commit de5600f0ff24, B200)

| Module | TFLOPS/sec | MFU |
|--------|-----------|-----|
| emb_preproc | 218.89 | 18.71% |
| seq_sum | 332.42 | 28.41% |
| seq_inter | 198.23 | 16.94% |
| nonseq_sum | 516.33 | 44.13% |

Expect ~1-2% run-to-run variance. Numbers outside this range indicate a real regression.
