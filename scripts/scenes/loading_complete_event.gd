class_name LoadingCompleteEvent extends GameEvent

## Emitted when loading.tscn finishes loading all resources and the target
## scene has been added to the scene tree (before the iris-out transition).
##
## Properties:
## - target_scene: path of the scene that was loaded (e.g. "res://scenes/main.tscn")
## - mode: loading mode ("global" for startup, "level" for level transitions)

## The scene path that was loaded as the target
var target_scene: String = ""

## Loading mode: "global" or "level"
var mode: String = ""
