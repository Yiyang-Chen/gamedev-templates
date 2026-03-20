# EventSystem

Provides decoupled event communication using class-based strong typing.

## Core API

```gdscript
var event_sys: EventSystem = EnvironmentRuntime.get_system("EventSystem") as EventSystem

# Register handler (pass class type, not string)
event_sys.register(PlayerJumpEvent, _on_player_jump)

# Unregister handler (must be same reference)
event_sys.unregister(PlayerJumpEvent, _on_player_jump)

# One-time handler (auto-removes after first trigger)
event_sys.once(PlayerDiedEvent, _on_player_died)

# Trigger event
var event: PlayerJumpEvent = PlayerJumpEvent.new(player, -500)
event_sys.trigger(event)

# Deferred trigger (executes at end of frame)
event_sys.trigger_deferred(event)
```

## Creating Events

All events must extend `GameEvent` and declare a `class_name`:

```gdscript
class_name PlayerJumpEvent extends GameEvent

var player: Node
var velocity: float

func _init(p_player: Node, p_velocity: float) -> void:
    player = p_player
    velocity = p_velocity
```

## Handler Signature

Handlers must accept exactly one parameter (the GameEvent subclass):

```gdscript
func _on_player_jump(event: PlayerJumpEvent) -> void:
    print("Player jumped with velocity: %s" % event.velocity)
```

## Lifecycle and Cleanup

EventSystem uses Godot's `CONNECT_REFERENCE_COUNTED` flag, which provides automatic cleanup when objects are destroyed. However, you should still explicitly unregister listeners when they are no longer needed.

Common cleanup patterns:
- **Scene nodes**: unregister in `_exit_tree()` to clean up any remaining listeners
- **UIPanel subclasses**: use `_bind_events()` / `_unbind_events()` (managed by UISystem focus lifecycle)
- **Business logic**: register/unregister at the appropriate lifecycle points for your use case

Failing to unregister can cause callbacks to reference freed objects and crash.

## Utility Methods

```gdscript
# Check if event type has handlers
event_sys.has_handlers(PlayerJumpEvent)

# Get handler count
event_sys.get_handler_count(PlayerJumpEvent)

# Clear all handlers for a type
event_sys.clear_event_type(PlayerJumpEvent)

# Clear all handlers
event_sys.clear_all()

# List all registered event types
var types: Array[String] = event_sys.get_registered_event_types()
```
