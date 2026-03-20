# GodotBase - Coding Guide

## Requirements

- Godot Engine 4.5+
- Web export templates installed
- Modern web browser

## Accessing Systems

Use `EnvironmentRuntime` to get systems from scene scripts or nodes:

```gdscript
func _ready():
    # Get system from default environment
    var logger = EnvironmentRuntime.get_system("LogSystem")
    var events = EnvironmentRuntime.get_system("EventSystem")
    var web = EnvironmentRuntime.get_system("WebBridgeSystem")
    var resources = EnvironmentRuntime.get_system("ResourceSystem")
```

## Systems

### LogSystem

Unified logging interface. **All code must use `LogSystem` for logging. Never use `print()`, `push_warning()`, or `push_error()` directly — no exceptions.**

Before writing any logging code, read `docs/coding/log_system.md` for available helper functions.

### EventSystem

Event-based decoupled communication. **Ensure all registered event listeners are unregistered before the node is freed.** Use `_exit_tree()` as a safety net to clean up any remaining listeners. Unregistered callbacks referencing freed objects will cause crashes.

Before developing event-related features, read `docs/coding/event_system.md` for registration patterns and lifecycle.

### ResourceSystem

Resource loading and caching (remote and local). **Do not load resources before `ResourceController._ready()` is called.**

Before developing resource loading features, read `docs/coding/resource_system.md` for timing constraints and configuration.

### FontSystem

Dynamic font loading from PCK. Current font asset only supports English and Chinese.

Before working with fonts, read `docs/coding/font_system.md` for the loading workflow.

### SceneSystem

Scene loading and management. **Always use `SceneSystem` for scene operations. Never use `get_tree().change_scene_to_file()` or `get_tree().change_scene_to_packed()`.**

Before developing scene-related features, read `docs/coding/scene_system.md` for the full API and scene flow.

### AudioSystem

BGM and SFX playback. **Never create AudioStreamPlayer nodes manually, always use AudioSystem.**

Before developing audio features, read `docs/coding/audio_system.md` for the full API and usage constraints.

### WebBridgeSystem

JavaScript/web communication bridge. Check `OS.has_feature("web")` before any web-specific code.

## Scene Flow

`index.tscn` is the bootstrap scene — it loads `loading.tscn` then destroys itself. Do not add game logic to it.

Flow: `index.tscn` → `loading.tscn` → `main.tscn` → other scenes

The `target_scene` is configured in `index.gd`. To change the game scene you want to show, update this parameter. When scene code doesn't execute as expected, first verify `target_scene` points to the correct scene.

For loading scene preloading workflow, read `docs/coding/loading_scene.md`.

## Before Calling Project Functions

**Always check function signatures before calling project-defined functions.**

1. Read `.agent_index/script_symbols.json` to find the function
2. Verify parameter types and order
3. Do not assume API signatures from memory

See `indexing-guide.md` for detailed query workflows.

## Building

```bash
# Build for web
./build.sh

# Clean build artifacts
./tools/clean.sh

# Generate Godot UIDs for .tscn files
./tools/make.sh

# Also generate .gd.uid files (usually unnecessary, auto-generated during build)
./tools/make.sh --scripts
```

## Restrictions

**NEVER modify `public/assets/game_config.json`** — this file is auto-registered by tools.

## Debugging

- First check browser console for JavaScript errors if available.
- Analyze the information and check indexing files. Think about possible causes of the bug.
- Godot headless can help reproduce bugs and verify fixes.

## Best Practices

- Check indexing to plan your task. Avoid building duplicate functions
- Check indexing before you call a function to use it correctly
- Always check `OS.has_feature("web")` before web-specific code
- Do not build unnecessary builds by calling `build.sh` frequently
- Use systems instead of native Godot features if available (both in system code and game logic). Examples: `LogSystem` instead of `print()`, `SceneSystem` instead of `get_tree().change_scene()`
- Be careful if you really want to change logic in systems. Lots of logic rely on systems and should be stable enough
- When scene code doesn't execute as expected, first verify `target_scene` in `index.gd` points to the correct scene
