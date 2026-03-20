# SceneSystem

Manages scene loading and unloading. **Always use SceneSystem for scene operations.**

## Core API

```gdscript
var scene_system: SceneSystem = EnvironmentRuntime.get_system("SceneSystem") as SceneSystem

# Load a scene (can send custom data)
scene_system.load_scene("res://scenes/game.tscn")

# Unload a scene
scene_system.unload_scene("res://scenes/menu.tscn")
```

## Forbidden Methods

**Never use native Godot scene methods:**
- `get_tree().change_scene_to_file()` — forbidden
- `get_tree().change_scene_to_packed()` — forbidden

These bypass SceneSystem's lifecycle management and will cause inconsistent state.

## Scene Flow

`index.tscn` is the bootstrap scene — it loads `loading.tscn` then destroys itself.

```
index.tscn → loading.tscn → main.tscn → other scenes
```

- `target_scene` is configured in `index.gd`. To change the game scene, update this parameter.
- Add game logic to `main.tscn` or later scenes, not to `index.tscn`.
- Preload large assets via ResourceSystem in the loading scene. See `docs/coding/loading_scene.md`.
- When scene code doesn't execute as expected, first verify `target_scene` in `index.gd` points to the correct scene.
