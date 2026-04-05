# PyTorch Coding Style & Patterns

## Coding Style

- Minimize comments; be concise; code should be self-explanatory and self-documenting.
- Comments should be useful — remind the reader about global context that is
  non-obvious and can't be inferred locally.
- Don't make trivial (1-2 LOC) helper functions that are only used once unless
  it significantly improves code readability.
- Prefer clear abstractions. State management should be explicit.
  Don't dynamically `setattr`/`getattr` fields — use a clear class definition.
- Match existing code style and architectural patterns.
- If uncertain, choose the simpler, more concise implementation.

## Testing

Use the test class and runner:

```python
from torch.testing._internal.common_utils import run_tests, TestCase

class TestFeature(TestCase):
    ...

if __name__ == "__main__":
    run_tests()
```

- Use `assertEqual` for tensor equality (not `torch.allclose`)
- Use `@parametrize` for tests over multiple inputs
- Use `instantiate_device_type_tests` for device-generic tests
- Use `@dtypes(...)` instead of manual dtype loops
- Use `make_tensor(shape, device=device, dtype=dtype)` instead of `torch.rand(shape)`
- Use `OpInfo` for operator tests, `ModuleInfo` for nn.Module tests

## Build

All build is done via `pip install -e . -v --no-build-isolation`.
Never run any other command to build PyTorch.

## Linting

Use `spin` for linting:
- `spin lint` — run linters
- `spin fixlint` — auto-apply fixes

## Dynamo Config

Use `torch._dynamo.config.patch` as decorator or context manager:

```python
@torch._dynamo.config.patch(force_compile_during_fx_trace=True)
def test_my_feature(self):
    pass

with torch._dynamo.config.patch(force_compile_during_fx_trace=True):
    pass
```

Never manually save/restore config values.

## Logging & Structured Tracing

For production debugging, use `trace_structured`:

```python
from torch._logging import trace_structured

trace_structured(
    "artifact",
    metadata_fn=lambda: {"name": "my_debug_artifact", "encoding": "string"},
    payload_fn=lambda: my_content_string,
)
```

Check if tracing is enabled:

```python
from torch._logging._internal import trace_log
if trace_log.handlers:
    msg += "[Use tlparse to extract debug artifacts]"
```

Best practices:
- Always log to `trace_structured` for production (no runtime cost if disabled)
- In error messages, tell users about both local files and `tlparse`
- Use `_get_unique_path()` to avoid overwriting debug files

## Commit Messages

- Don't make a bullet list of individual changes
- For large PRs, explain the order to review changes
- For short PRs, omit the bullet list entirely
- Disclose that the PR was authored with Claude
- Preserve `ghstack-source-id` or `Pull-Request` trailers when rewriting commits
