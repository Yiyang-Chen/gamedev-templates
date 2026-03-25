extends Node

## Main Scene - Fruit Defense Tower Defense Game
##
## Assembles all game layers and connects UI signals to game logic.

var _game_manager: TDGameManager = null
var _hud: TDHUD = null
var _map_renderer: TDMapRenderer = null
var _log: LogSystem = null
var _scene_system: SceneSystem = null


func _ready() -> void:
	_log = EnvironmentRuntime.get_system("LogSystem") as LogSystem
	_scene_system = EnvironmentRuntime.get_system("SceneSystem") as SceneSystem
	_log.debug("[Main] Ready - Fruit Defense")

	var game_layer: Node = get_node("GameLayer")
	var ui_layer: Control = get_node("UILayer") as Control

	var game_root: Node2D = Node2D.new()
	game_root.name = "GameRoot"
	game_layer.add_child(game_root)

	_map_renderer = TDMapRenderer.new()
	_map_renderer.name = "MapRenderer"
	game_root.add_child(_map_renderer)

	var enemy_layer: Node2D = Node2D.new()
	enemy_layer.name = "EnemyLayer"
	game_root.add_child(enemy_layer)

	var tower_layer: Node2D = Node2D.new()
	tower_layer.name = "TowerLayer"
	game_root.add_child(tower_layer)

	var projectile_layer: Node2D = Node2D.new()
	projectile_layer.name = "ProjectileLayer"
	game_root.add_child(projectile_layer)

	_game_manager = TDGameManager.new()
	_game_manager.name = "GameManager"
	game_root.add_child(_game_manager)
	_game_manager.initialize(_map_renderer, enemy_layer, tower_layer, projectile_layer)

	_hud = TDHUD.new()
	_hud.name = "HUD"
	ui_layer.add_child(_hud)

	_game_manager.money_changed.connect(_hud.update_money)
	_game_manager.lives_changed.connect(_hud.update_lives)
	_game_manager.wave_changed.connect(_hud.update_wave)
	_game_manager.tower_selected.connect(_hud.show_tower_info)
	_game_manager.tower_deselected.connect(_hud.hide_tower_info)
	_game_manager.game_over.connect(_on_game_over)
	_game_manager.wave_complete.connect(_on_wave_complete)

	_hud.tower_button_pressed.connect(_game_manager.start_placing)
	_hud.upgrade_pressed.connect(_game_manager.upgrade_selected)
	_hud.sell_pressed.connect(_game_manager.sell_selected)
	_hud.start_wave_pressed.connect(_game_manager.start_wave)
	_hud.restart_pressed.connect(_restart_game)


func _unhandled_input(event: InputEvent) -> void:
	if _game_manager == null:
		return

	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_game_manager.handle_click(mb.position)
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			_game_manager.cancel_placing()
			_game_manager.deselect_tower()

	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		_game_manager.handle_hover(mm.position)


func _on_game_over(won: bool) -> void:
	_hud.show_game_over(won)


func _on_wave_complete() -> void:
	_hud.set_wave_btn_enabled(true)


func _restart_game() -> void:
	Engine.time_scale = 1.0
	_scene_system.load_scene("res://scenes/main.tscn")
