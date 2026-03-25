class_name TDGameManager extends Node2D

## Main game manager that orchestrates the tower defense game.
## Creates and wires all components: map, enemies, towers, UI, waves.

var _gold: int = TDGameData.START_GOLD
var _lives: int = TDGameData.START_LIVES
var _game_speed: float = 1.0
var _game_over: bool = false
var _selected_tower_type: int = -1

var _map: TDMap = null
var _enemies_container: Node2D = null
var _towers_container: Node2D = null
var _projectiles_container: Node2D = null
var _wave_manager: TDWaveManager = null

var _hud: TDHUD = null
var _tower_panel: TDTowerPanel = null
var _upgrade_panel: TDUpgradePanel = null
var _game_over_panel: TDGameOverPanel = null

var _placed_towers: Dictionary = {}
var _path_world_points: Array[Vector2] = []

var _build_preview_pos: Vector2i = Vector2i(-1, -1)
var _build_preview_valid: bool = false


func _ready() -> void:
	_setup_game()


func _setup_game() -> void:
	_gold = TDGameData.START_GOLD
	_lives = TDGameData.START_LIVES
	_game_speed = 1.0
	_game_over = false
	_selected_tower_type = -1
	_placed_towers.clear()

	_clear_children()
	_create_path_points()
	_create_map()
	_create_containers()
	_create_ui()
	_create_wave_manager()
	_update_ui()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()


func _create_path_points() -> void:
	_path_world_points.clear()
	var raw_points: Array[Vector2i] = TDGameData.get_path_points()
	for pt: Vector2i in raw_points:
		_path_world_points.append(Vector2(
			pt.x * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2,
			pt.y * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2
		))


func _create_map() -> void:
	_map = TDMap.new()
	_map.setup()
	add_child(_map)


func _create_containers() -> void:
	_enemies_container = Node2D.new()
	_enemies_container.name = "Enemies"
	add_child(_enemies_container)

	_towers_container = Node2D.new()
	_towers_container.name = "Towers"
	add_child(_towers_container)

	_projectiles_container = Node2D.new()
	_projectiles_container.name = "Projectiles"
	add_child(_projectiles_container)


func _create_ui() -> void:
	var ui_layer: CanvasLayer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)

	# HUD
	_hud = TDHUD.new()
	_hud.name = "HUD"
	_hud.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_hud.size = Vector2(1280, 40)
	_hud.next_wave_requested.connect(_on_next_wave)
	_hud.speed_changed.connect(_on_speed_changed)
	ui_layer.add_child(_hud)

	# Tower selection panel (right side)
	_tower_panel = TDTowerPanel.new()
	_tower_panel.name = "TowerPanel"
	_tower_panel.position = Vector2(1280 - 70, 44)
	_tower_panel.size = Vector2(70, 420)
	_tower_panel.tower_type_selected.connect(_on_tower_type_selected)
	_tower_panel.tower_type_deselected.connect(_on_tower_type_deselected)
	_tower_panel.setup()
	ui_layer.add_child(_tower_panel)

	# Upgrade panel
	_upgrade_panel = TDUpgradePanel.new()
	_upgrade_panel.name = "UpgradePanel"
	_upgrade_panel.size = Vector2(220, 80)
	_upgrade_panel.upgrade_requested.connect(_on_upgrade_tower)
	_upgrade_panel.sell_requested.connect(_on_sell_tower)
	_upgrade_panel.panel_closed.connect(_on_upgrade_panel_closed)
	ui_layer.add_child(_upgrade_panel)

	# Game over panel
	_game_over_panel = TDGameOverPanel.new()
	_game_over_panel.name = "GameOverPanel"
	_game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_panel.size = Vector2(1280, 720)
	_game_over_panel.retry_requested.connect(_on_retry)
	ui_layer.add_child(_game_over_panel)


func _create_wave_manager() -> void:
	_wave_manager = TDWaveManager.new()
	_wave_manager.setup(_path_world_points)
	_wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	_wave_manager.wave_started.connect(_on_wave_started)
	_wave_manager.wave_cleared.connect(_on_wave_cleared)
	_wave_manager.all_waves_complete.connect(_on_all_waves_complete)


func _process(delta: float) -> void:
	if _game_over:
		return

	var scaled_delta: float = delta * _game_speed
	_wave_manager.process(scaled_delta, _enemies_container)
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return

	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_handle_click(mb.position)
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_tower_panel.deselect()
			_upgrade_panel.hide_panel()
			_selected_tower_type = -1

	if event is InputEventMouseMotion:
		@warning_ignore("unsafe_cast")
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		_handle_mouse_move(mm.position)


func _handle_click(screen_pos: Vector2) -> void:
	var world_pos: Vector2 = screen_pos
	var cell: Vector2i = _map.world_to_cell(world_pos)

	if _selected_tower_type >= 0:
		_try_place_tower(cell)
		return

	# Check if clicking an existing tower
	var key: String = "%d_%d" % [cell.x, cell.y]
	if _placed_towers.has(key):
		var tower: TDTower = _placed_towers[key]
		_upgrade_panel.show_for_tower(tower, _gold)
		_tower_panel.deselect()
		_selected_tower_type = -1
	else:
		_upgrade_panel.hide_panel()


func _handle_mouse_move(screen_pos: Vector2) -> void:
	if _selected_tower_type < 0:
		_build_preview_pos = Vector2i(-1, -1)
		queue_redraw()
		return

	var cell: Vector2i = _map.world_to_cell(screen_pos)
	_build_preview_pos = cell
	_build_preview_valid = _can_build_at(cell)
	queue_redraw()


func _can_build_at(cell: Vector2i) -> bool:
	if not _map.is_buildable(cell.x, cell.y):
		return false
	var key: String = "%d_%d" % [cell.x, cell.y]
	if _placed_towers.has(key):
		return false
	return true


func _try_place_tower(cell: Vector2i) -> void:
	if not _can_build_at(cell):
		return

	var stats: TDGameData.TowerStats = TDGameData.get_tower_stats(_selected_tower_type, 0)
	if _gold < stats.cost:
		return

	_gold -= stats.cost

	var tower: TDTower = TDTower.new()
	tower.setup(_selected_tower_type, cell, _enemies_container, _projectiles_container)
	_towers_container.add_child(tower)

	var key: String = "%d_%d" % [cell.x, cell.y]
	_placed_towers[key] = tower

	_update_ui()


func _update_ui() -> void:
	if _hud:
		_hud.update_display(
			_gold, _lives,
			_wave_manager.get_current_wave(),
			_wave_manager.get_total_waves(),
			_wave_manager.is_wave_active()
		)
	if _tower_panel:
		_tower_panel.update_gold(_gold)
	if _upgrade_panel:
		_upgrade_panel.update_gold(_gold)


# ========================================
# Signal Handlers
# ========================================

func _on_enemy_spawned(enemy: TDEnemy) -> void:
	enemy.enemy_killed.connect(_on_enemy_killed)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)


func _on_enemy_killed(enemy: TDEnemy) -> void:
	_gold += enemy.reward
	_update_ui()
	# Delayed cleanup
	var tween: Tween = create_tween()
	tween.tween_property(enemy, "modulate:a", 0.0, 0.3)
	tween.tween_callback(enemy.queue_free)


func _on_enemy_reached_end(enemy: TDEnemy) -> void:
	_lives -= 1
	_update_ui()
	enemy.queue_free()

	if _lives <= 0:
		_lives = 0
		_game_over = true
		_game_over_panel.show_result(false, _wave_manager.get_current_wave())


func _on_wave_started(_wave_number: int) -> void:
	_update_ui()


func _on_wave_cleared(wave_number: int) -> void:
	_gold += TDGameData.WAVE_CLEAR_BONUS
	_update_ui()
	# Check if this was the last wave
	if wave_number >= _wave_manager.get_total_waves():
		_game_over = true
		_game_over_panel.show_result(true, wave_number)


func _on_all_waves_complete() -> void:
	pass


func _on_next_wave() -> void:
	_wave_manager.start_next_wave()


func _on_speed_changed(new_speed: float) -> void:
	_game_speed = new_speed
	Engine.time_scale = _game_speed


func _on_tower_type_selected(tt: int) -> void:
	_selected_tower_type = tt
	_upgrade_panel.hide_panel()


func _on_tower_type_deselected() -> void:
	_selected_tower_type = -1
	_build_preview_pos = Vector2i(-1, -1)
	queue_redraw()


func _on_upgrade_tower(tower: TDTower) -> void:
	if not tower.can_upgrade():
		return
	var cost: int = tower.get_upgrade_cost()
	if _gold < cost:
		return
	_gold -= cost
	tower.upgrade()
	_upgrade_panel.show_for_tower(tower, _gold)
	_update_ui()


func _on_sell_tower(tower: TDTower) -> void:
	_gold += tower.get_sell_value()
	var key: String = "%d_%d" % [tower.grid_pos.x, tower.grid_pos.y]
	_placed_towers.erase(key)
	tower.queue_free()
	_upgrade_panel.hide_panel()
	_update_ui()


func _on_upgrade_panel_closed() -> void:
	pass


func _on_retry() -> void:
	Engine.time_scale = 1.0
	_setup_game()


# ========================================
# Build Preview Drawing
# ========================================

func _draw() -> void:
	if _selected_tower_type < 0 or _build_preview_pos.x < 0:
		return

	var ts: float = float(TDGameData.TILE_SIZE)
	var rect: Rect2 = Rect2(
		float(_build_preview_pos.x) * ts,
		float(_build_preview_pos.y) * ts,
		ts, ts
	)

	if _build_preview_valid:
		draw_rect(rect, Color(0.2, 0.8, 0.3, 0.3))
		draw_rect(rect, Color(0.3, 1.0, 0.4, 0.5), false, 2.0)
		# Preview range circle
		var center: Vector2 = Vector2(rect.position.x + ts / 2.0, rect.position.y + ts / 2.0)
		var stats: TDGameData.TowerStats = TDGameData.get_tower_stats(_selected_tower_type, 0)
		draw_arc(center, stats.attack_range, 0, TAU, 48, Color(1, 1, 1, 0.15), 1.0)
	else:
		draw_rect(rect, Color(0.8, 0.2, 0.2, 0.3))
		draw_rect(rect, Color(1.0, 0.3, 0.3, 0.5), false, 2.0)
