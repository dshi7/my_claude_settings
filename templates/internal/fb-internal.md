# Domain — Triton / AI Compiler

Team: AI Compiler Performance (DevInfra - PL & Runtimes). Making GPUs go brrr.

# Repos and source control

/data/users/daohang/fbsource (hg/sl)
- buck commands (buck run, buck test)
- On Blackwell machines (B200, GB200), always add `@//mode/opt -c fbcode.platform010_cuda_version=12.8` to buck commands
- When debugging triton/TLX in fbsource, **never** use `python3 -c "from torch._inductor..."` or any standalone python command — fbcode-only modules (e.g., `fb/tlx_templates`) are not importable outside buck. Always add debug code/tests in fbsource and use `buck run`/`buck test` only.

/data/users/daohang/pytorch (git)
- build: see my bash alias 'build_pytorch'

/data/users/daohang/fbtriton (git)
- build: use 'make dev-install-llvm' instead of 'pip install ...'

# Host Context

I work across multiple devservers. Settings sync via dotsync2.
First run $HOSTNAME to know where you are.

devvm51168.lla0.facebook.com
- Compact VM — no GPU, not shared. Used for:
  - Agentic scheduling (myclaw, cron jobs, daily briefings)
  - Lightweight work: diffs, buck test, hg ops, code review, PR submission
  - Primary dev work stays on devgpu boxes

devgpu006.maz2.facebook.com
- B200 devgpu
- main devgpu for daily dev works
- has fbsource and fbtriton

devgpu031.atn1.facebook.com
- B200 devgpu
- secondary devgpu for daily dev works
- occasionally lose connection or require 'fbwallet_fetch'
- has fbsource, fbtriton OSS, pytorch OSS

devgpu035.snb3.facebook.com
- B200
- has fbsource and pytorch

devgpu004.maz2.facebook.com
- B200

devgpu067.nao5.facebook.com
- GB200

devgpu088.cco2.facebook.com/devgpu086.cco2.facebook.com
- H100
