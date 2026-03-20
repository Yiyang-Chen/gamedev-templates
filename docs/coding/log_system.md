# LogSystem

Unified logging interface. **All code must use LogSystem. Never use `print()`, `push_warning()`, or `push_error()` directly.**

## Helper Functions

Some base classes provide helper functions that already use LogSystem internally. Use these instead of accessing LogSystem directly:

- **`System` subclasses**: call `log_info()` / `log_warn()` / `log_error()` directly (inherited from System base class)

For code that does not inherit from a base class with helpers:

```gdscript
var logger: LogSystem = EnvironmentRuntime.get_system("LogSystem") as LogSystem
logger.info("message")
logger.warn("message")
logger.error("message")
```
