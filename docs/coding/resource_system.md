# ResourceSystem

Handles resource loading and caching (remote and local).

## Core API

```gdscript
var resources: ResourceSystem = EnvironmentRuntime.get_system("ResourceSystem") as ResourceSystem

# Preload a resource (async, fires event when ready)
resources.preload_resource("my_image_key")

# Load a resource (returns cached if available)
var texture: Texture2D = resources.load_resource("my_image_key")
```

## Important Constraints

- **Do not load resources before `ResourceController._ready()` is called.** The controller injects the Node needed for HTTP requests.
- After a resource is preloaded, `load_resource` may return the resource before a node is fully set up. Be careful with timing.
- All resources must be registered in `game_config.json` with their keys and paths.

## Configuration

Resources are configured in `public/assets/game_config.json`. **Never modify this file manually** — it is auto-registered by tools.

## Usage in Loading Scene

ResourceSystem is used heavily in the loading scene to preload assets needed by the next scene. See `docs/coding/loading_scene.md` for the preloading workflow.
