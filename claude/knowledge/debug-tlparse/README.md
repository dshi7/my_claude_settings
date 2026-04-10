# debug-tlparse Knowledge Base

tlparse is an OSS tool for parsing and analyzing PyTorch trace logs
(torch.compile structured logs). Used for debugging compilation issues,
Inductor code highlighting, and symbolic shape analysis.

## Local skill: `SKILL.md`

Debug workflow for tlparse issues — reproducing failures, analyzing verbose
output, proposing fixes, and updating the third-party crate version.
Invoke with:
```
/debug-tlparse
```

## Upstream

- OSS repo: https://github.com/yrmo/tlparse
- fbcode target: `fbcode//caffe2/fb/tlparse:tlparse`
