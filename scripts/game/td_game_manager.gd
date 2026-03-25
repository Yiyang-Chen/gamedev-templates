class_name TDGameManager extends Node2D
## Core game manager - handles waves, spawning, economy, input, and game state


signal money_changed(amount: int)
signal lives_changed(amount: int)
signal wave_changed(wave: int, total: int)
signal game_over(won: bool)
signal tower_selected(tower: TDTower)
signal tower_deselected()
signal tower_placing(type: int)
signal tower_place_cancelled()
signal wave_complete()


var money: int = TDData.START_MONEY
var lives: int = TDData.START_LIVES
var current_wave: int = 0
var is_wave_active: bool = false
var game_ended: bool = false

var _map_renderer: TDMapRenderer = null
var _enemy_layer: Node2D = null
var _tower_layer: Node2D = null
var _projectile_layer: Node2D = null
var _towers: Dictionary = {}
var _selected_tower: TDTower = null
var _placing_tower_type: int = -1
var _spawn_queue: Array = []
var _spawn_timer: float = 0.0
var _enemies_alive: int = 0
var _between_waves: bool = true
var _log: LogSystem = null


func _ready() -> void:
	_log = EnvironmentRuntime.get_system("LogSystem") as LogSystem
	_log.debug("[TDGameManager] Ready")


func initialize(map_r: TDMapRenderer, enemy_l: Node2D, tower_l: Node2D, proj_l: Node2D) -> void:
	_map_renderer = map_r
	_enemy_layer = enemy_l
	_tower_layer = tower_l
	_projectile_layer = proj_l
	money_changed.emit(money)
	lives_changed.emit(lives)
	wave_changed.emit(current_wave, TDData.TOTAL_WAVES)


func start_wave() -> void:
	if is_wave_active or game_ended:
		return
	if current_wave >= TDData.TOTAL_WAVES:
		return

	deselect_tower()
	cancel_placing()

	var wave_data: Array = TDData.WAVES[current_wave] as Array
	_spawn_queue.clear()

	for group: Variant in wave_data:
		var g: Array = group as Array
		var etype: int = g[0] as int
		var count: int = g[1] as int
		var interval: float = g[2] as float
		for i: int in range(count):
			_spawn_queue.push_back([etype, interval])

	is_wave_active = true
	_between_waves = false
	_spawn_timer = 0.0
	_enemies_alive = 0
	current_wave += 1
	wave_changed.emit(current_wave, TDData.TOTAL_WAVES)
	_log.debug("[TDGameManager] Wave %d started" % current_wave)


func start_placing(tower_type: int) -> void:
	if game_ended:
		return
	var cost: int = TDData.TOWER_COSTS[tower_type] as int
	if money < cost:
		return
	deselect_tower()
	_placing_tower_type = tower_type
	tower_placing.emit(tower_type)


func cancel_placing() -> void:
	if _placing_tower_type >= 0:
		_placing_tower_type = -1
		_map_renderer.clear_hover()
		tower_place_cancelled.emit()


func is_placing() -> bool:
	return _placing_tower_type >= 0


func deselect_tower() -> void:
	if _selected_tower != null:
		_selected_tower = null
		_map_renderer.clear_selection()
		tower_deselected.emit()


func select_tower_at(cell: Vector2i) -> void:
	var key: String = "%d_%d" % [cell.x, cell.y]
	if _towers.has(key):
		_selected_tower = _towers[key] as TDTower
		_map_renderer.set_selected(cell, _selected_tower.get_range())
		tower_selected.emit(_selected_tower)


func upgrade_selected() -> void:
	if _selected_tower == null or game_ended:
		return
	if not _selected_tower.can_upgrade():
		return
	var cost: int = _selected_tower.get_upgrade_cost()
	if money < cost:
		return
	money -= cost
	_selected_tower.upgrade()
	money_changed.emit(money)
	_map_renderer.set_selected(
		Vector2i(_selected_tower.grid_col, _selected_tower.grid_row),
		_selected_tower.get_range())
	tower_selected.emit(_selected_tower)


func sell_selected() -> void:
	if _selected_tower == null or game_ended:
		return
	var refund: int = _selected_tower.get_sell_price()
	var key: String = "%d_%d" % [_selected_tower.grid_col, _selected_tower.grid_row]
	_towers.erase(key)
	_selected_tower.queue_free()
	money += refund
	money_changed.emit(money)
	deselect_tower()


func _process(delta: float) -> void:
	if game_ended:
		return

	if is_wave_active:
		_process_spawning(delta)
		if _spawn_queue.is_empty() and _enemies_alive <= 0:
			is_wave_active = false
			_between_waves = true
			wave_complete.emit()
			_log.debug("[TDGameManager] Wave %d complete" % current_wave)
			if current_wave >= TDData.TOTAL_WAVES:
				_end_game(true)


func _process_spawning(delta: float) -> void:
	if _spawn_queue.is_empty():
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var entry: Array = _spawn_queue.pop_front() as Array
		var etype: int = entry[0] as int
		var interval: float = entry[1] as float
		_spawn_enemy(etype)
		_spawn_timer = interval


func _spawn_enemy(etype: int) -> void:
	var enemy: TDEnemy = TDEnemy.new()
	enemy.setup(etype, TDData.PATH_WAYPOINTS, current_wave - 1)
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)
	_enemy_layer.add_child(enemy)
	_enemies_alive += 1


func _on_enemy_died(enemy: TDEnemy) -> void:
	_enemies_alive -= 1
	money += enemy.reward
	money_changed.emit(money)


func _on_enemy_reached_end(_enemy: TDEnemy) -> void:
	_enemies_alive -= 1
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		_end_game(false)


func _on_tower_shot(tower: TDTower, target: TDEnemy) -> void:
	var proj: TDProjectile = TDProjectile.new()
	proj.setup(tower, target, _enemy_layer)
	_projectile_layer.add_child(proj)


func _end_game(won: bool) -> void:
	game_ended = true
	is_wave_active = false
	game_over.emit(won)
	_log.debug("[TDGameManager] Game over - Won: %s" % str(won))


func handle_click(pos: Vector2) -> void:
	if game_ended:
		return

	var cell: Vector2i = TDData.pixel_to_grid(pos)

	if _placing_tower_type >= 0:
		_try_place_tower(cell)
		return

	var key: String = "%d_%d" % [cell.x, cell.y]
	if _towers.has(key):
		select_tower_at(cell)
	else:
		deselect_tower()


func handle_hover(pos: Vector2) -> void:
	if _placing_tower_type < 0:
		return
	var cell: Vector2i = TDData.pixel_to_grid(pos)
	var key: String = "%d_%d" % [cell.x, cell.y]
	var valid: bool = _can_build_at(cell) and not _towers.has(key)
	_map_renderer.set_hover(cell, valid)


func _try_place_tower(cell: Vector2i) -> void:
	var key: String = "%d_%d" % [cell.x, cell.y]
	if not _can_build_at(cell) or _towers.has(key):
		return
	var cost: int = TDData.TOWER_COSTS[_placing_tower_type] as int
	if money < cost:
		return

	money -= cost
	money_changed.emit(money)

	var tower: TDTower = TDTower.new()
	tower.setup(_placing_tower_type, cell.x, cell.y, _enemy_layer)
	tower.tower_shot.connect(_on_tower_shot)
	_tower_layer.add_child(tower)
	_towers[key] = tower

	cancel_placing()


func _can_build_at(cell: Vector2i) -> bool:
	return TDData.is_buildable(cell.x, cell.y)
