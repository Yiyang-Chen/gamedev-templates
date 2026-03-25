class_name TDWaveManager extends RefCounted

## Manages wave spawning logic.

var _waves: Array[TDGameData.WaveData] = []
var _current_wave_index: int = -1
var _current_entry_index: int = 0
var _spawn_count: int = 0
var _spawn_timer: float = 0.0
var _entry_delay_timer: float = 0.0
var _wave_active: bool = false
var _wave_complete: bool = false
var _path_world_points: Array[Vector2] = []

var total_enemies_spawned: int = 0
var total_enemies_finished: int = 0

signal enemy_spawned(enemy: TDEnemy)
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_complete()

func setup(path_points: Array[Vector2]) -> void:
	_waves = TDGameData.get_waves()
	_path_world_points = path_points
	_current_wave_index = -1
	_wave_active = false

func get_current_wave() -> int:
	return _current_wave_index + 1

func get_total_waves() -> int:
	return _waves.size()

func is_wave_active() -> bool:
	return _wave_active

func is_all_waves_done() -> bool:
	return _current_wave_index >= _waves.size() - 1 and not _wave_active

func start_next_wave() -> bool:
	if _wave_active:
		return false
	_current_wave_index += 1
	if _current_wave_index >= _waves.size():
		all_waves_complete.emit()
		return false

	_current_entry_index = 0
	_spawn_count = 0
	_spawn_timer = 0.0
	var wave: TDGameData.WaveData = _waves[_current_wave_index]
	if wave.entries.size() > 0:
		_entry_delay_timer = wave.entries[0].delay_before
	else:
		_entry_delay_timer = 0.0
	_wave_active = true
	_wave_complete = false
	total_enemies_spawned = 0
	total_enemies_finished = 0

	wave_started.emit(_current_wave_index + 1)
	return true

func process(delta: float, enemies_container: Node) -> void:
	if not _wave_active:
		return

	var wave: TDGameData.WaveData = _waves[_current_wave_index]
	if _current_entry_index >= wave.entries.size():
		_check_wave_complete(enemies_container)
		return

	var entry: TDGameData.WaveEntry = wave.entries[_current_entry_index]

	if _entry_delay_timer > 0.0:
		_entry_delay_timer -= delta
		return

	_spawn_timer += delta
	if _spawn_timer >= entry.spawn_interval and _spawn_count < entry.count:
		_spawn_timer = 0.0
		_spawn_enemy(entry.enemy_type, wave, enemies_container)
		_spawn_count += 1

		if _spawn_count >= entry.count:
			_current_entry_index += 1
			_spawn_count = 0
			_spawn_timer = 0.0
			if _current_entry_index < wave.entries.size():
				_entry_delay_timer = wave.entries[_current_entry_index].delay_before

	_check_wave_complete(enemies_container)

func _spawn_enemy(enemy_type: int, wave: TDGameData.WaveData, container: Node) -> void:
	var enemy: TDEnemy = TDEnemy.new()
	var path_copy: Array[Vector2] = []
	for p: Vector2 in _path_world_points:
		path_copy.append(p)
	enemy.setup(enemy_type, path_copy, wave.hp_multiplier, wave.speed_multiplier)
	container.add_child(enemy)
	total_enemies_spawned += 1
	enemy_spawned.emit(enemy)

func _check_wave_complete(enemies_container: Node) -> void:
	if _wave_complete:
		return

	var wave: TDGameData.WaveData = _waves[_current_wave_index]
	if _current_entry_index < wave.entries.size():
		return

	var alive_count: int = 0
	for child: Node in enemies_container.get_children():
		if child is TDEnemy:
			@warning_ignore("unsafe_cast")
			var enemy: TDEnemy = child as TDEnemy
			if not enemy.is_dead and not enemy.reached_end:
				alive_count += 1

	if alive_count == 0:
		_wave_active = false
		_wave_complete = true
		wave_cleared.emit(_current_wave_index + 1)
