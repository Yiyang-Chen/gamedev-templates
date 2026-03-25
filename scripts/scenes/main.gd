extends Node

## Main Scene - Tower Defense Game Entry Point
##
## Loaded after loading.tscn completes. All global resources are ready.
## Instantiates and adds the TDGameManager to GameLayer.


func _ready() -> void:
	var log: LogSystem = EnvironmentRuntime.get_system("LogSystem") as LogSystem
	log.debug("[Main] Ready - Starting Tower Defense Game")

	# Create game manager and add to GameLayer
	var game_manager: TDGameManager = TDGameManager.new()
	game_manager.name = "TDGameManager"
	$GameLayer.add_child(game_manager)
