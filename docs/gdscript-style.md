# GDScript 4.x Project Requirements

## Critical Rules

1. **This project MUST be implemented entirely in GDScript**
2. **This project MUST use Godot 4.x GDScript syntax**
3. **GDScript is NOT Python - do not confuse them**
4. **All classes MUST explicitly declare inheritance** (e.g., `extends RefCounted`, `extends Node`, `extends Resource`) - no implicit inheritance
5. **No emojis allowed** - Do not use any emoji characters in code, strings, comments, or UI text

## Strict Type Checking

This project enforces explicit typing so that every variable, parameter, and return value clearly communicates its purpose and data type. This makes the codebase easier to understand and maintain.

Errors (=2, will fail to run):
- `inferred_declaration` — `:=` is forbidden. Always use explicit types: `var x: String = "hello"`
- `untyped_declaration` — all variables, parameters, and return types must have explicit type annotations

These are errors because explicit types are the primary way to communicate intent. When you read `var speed: float = 10.0` instead of `var speed := 10.0`, the type is immediately clear without needing to trace the assigned value.

Warnings (=1, will not block execution but should be minimized):
- `unsafe_cast` — `value as float` on Variant. Prefer casting to a known type when possible
- `unsafe_call_argument` — passing Variant to typed parameters, including constructors like `float()`, `int()`
- `unsafe_method_access` — calling methods on Variant. Prefer casting first: `var btn: Button = node as Button`
- `unsafe_property_access` — accessing properties on Variant. Prefer casting first

These are warnings (not errors) because Variant is unavoidable in many common patterns — Dictionary values, engine callbacks, and generic Node references all return Variant. Forcing zero warnings here would require overly complex workarounds (parallel typed arrays instead of Dictionary, excessive `@warning_ignore` annotations) that hurt readability — the opposite of the goal.

The right approach: write clean code that naturally reduces unsafe warnings — use explicit types, cast to known types before accessing members. But do NOT increase code complexity or refactor data structures solely to suppress warnings. Simple `as Type` casts and direct Dictionary access are acceptable when the alternative would be overly verbose.

## Best Practice: Use SceneSystem

Always use `SceneSystem` for scene operations (see `coding.md`). Never use native Godot methods like `get_tree().change_scene_to_file()`.

## Engine-Level GDScript Knowledge

For Godot engine rules beyond this project's conventions, use `search_knowledge_base` with `category_key="godot_engine"`.
