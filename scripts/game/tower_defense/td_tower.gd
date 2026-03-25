class_name TDTower extends Node2D

## A fruit tower that attacks enemies in range.

var tower_type: int = TDGameData.TowerType.WATERMELON
var level: int = 0
var grid_pos: Vector2i = Vector2i.ZERO

var _stats: TDGameData.TowerStats = null
var _attack_timer: float = 0.0
var _target: TDEnemy = null
var _body_color: Color = Color.GREEN
var _accent_color: Color = Color.RED
var _anim_time: float = 0.0
var _attack_flash: float = 0.0

var enemies_container: Node = null
var projectiles_container: Node = null

var _range_circle_visible: bool = false

signal tower_fired(tower: TDTower, target_enemy: TDEnemy)

func setup(tt: int, gp: Vector2i, enemies: Node, projectiles: Node) -> void:
	tower_type = tt
	grid_pos = gp
	enemies_container = enemies
	projectiles_container = projectiles
	level = 0
	_stats = TDGameData.get_tower_stats(tower_type, level)
	_body_color = TDGameData.TOWER_COLORS[tower_type]
	_accent_color = TDGameData.TOWER_ACCENT_COLORS[tower_type]
	position = Vector2(
		gp.x * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2,
		gp.y * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2
	)

func get_stats() -> TDGameData.TowerStats:
	return _stats

func can_upgrade() -> bool:
	return level < 3

func get_upgrade_cost() -> int:
	if not can_upgrade():
		return 0
	return _stats.upgrade_cost

func get_sell_value() -> int:
	var total: int = TDGameData.get_tower_stats(tower_type, 0).cost
	for i: int in range(level):
		total += TDGameData.get_tower_stats(tower_type, i).upgrade_cost
	@warning_ignore("narrowing_conversion")
	return int(total * 0.6)

func upgrade() -> void:
	if not can_upgrade():
		return
	level += 1
	_stats = TDGameData.get_tower_stats(tower_type, level)
	_body_color = TDGameData.TOWER_COLORS[tower_type].lightened(0.05 * float(level))
	queue_redraw()

func show_range(visible_flag: bool) -> void:
	_range_circle_visible = visible_flag
	queue_redraw()

func _process(delta: float) -> void:
	_anim_time += delta
	if _attack_flash > 0.0:
		_attack_flash -= delta

	_attack_timer += delta
	var interval: float = 1.0 / _stats.attack_speed

	if _attack_timer >= interval:
		_find_target()
		if _target != null:
			_fire()
			_attack_timer = 0.0

	queue_redraw()

func _find_target() -> void:
	_target = null
	if enemies_container == null:
		return

	var best_enemy: TDEnemy = null
	var best_progress: int = -1

	for child: Node in enemies_container.get_children():
		if child is TDEnemy:
			@warning_ignore("unsafe_cast")
			var enemy: TDEnemy = child as TDEnemy
			if enemy.is_dead or enemy.reached_end:
				continue
			var dist: float = position.distance_to(enemy.position)
			if dist <= _stats.attack_range:
				if enemy.current_path_index > best_progress:
					best_progress = enemy.current_path_index
					best_enemy = enemy

	_target = best_enemy

func _fire() -> void:
	if _target == null or projectiles_container == null:
		return

	var proj: TDProjectile = TDProjectile.new()
	proj.position = position
	proj.setup(_target, tower_type, _stats.damage, _stats.special_value)
	projectiles_container.add_child(proj)
	_attack_flash = 0.15
	tower_fired.emit(self, _target)

func _draw() -> void:
	if _range_circle_visible:
		draw_arc(Vector2.ZERO, _stats.attack_range, 0, TAU, 48, Color(1, 1, 1, 0.15), 1.5)
		draw_circle(Vector2.ZERO, _stats.attack_range, Color(1, 1, 1, 0.05))

	var base_r: float = 20.0 + float(level) * 2.0
	var flash_mod: float = 1.0 + _attack_flash * 2.0

	# Shadow
	draw_circle(Vector2(2, 4), base_r * 0.9, Color(0, 0, 0, 0.15))

	match tower_type:
		TDGameData.TowerType.WATERMELON:
			_draw_watermelon(base_r, flash_mod)
		TDGameData.TowerType.STRAWBERRY:
			_draw_strawberry(base_r, flash_mod)
		TDGameData.TowerType.ORANGE:
			_draw_orange(base_r, flash_mod)
		TDGameData.TowerType.GRAPE:
			_draw_grape(base_r, flash_mod)
		TDGameData.TowerType.PINEAPPLE:
			_draw_pineapple(base_r, flash_mod)

	# Level stars
	for i: int in range(level):
		var sx: float = -6.0 + float(i) * 7.0
		draw_circle(Vector2(sx, base_r + 6.0), 2.5, Color(1.0, 0.85, 0.0))

func _draw_watermelon(r: float, flash: float) -> void:
	var c: Color = _body_color * flash
	draw_circle(Vector2.ZERO, r, c)
	draw_arc(Vector2.ZERO, r * 0.95, 0, TAU, 24, c.darkened(0.3), 2.0)
	# Stripes
	for i: int in range(5):
		var angle: float = float(i) * TAU / 5.0 + _anim_time * 0.2
		var p1: Vector2 = Vector2(cos(angle), sin(angle)) * r * 0.3
		var p2: Vector2 = Vector2(cos(angle), sin(angle)) * r * 0.9
		draw_line(p1, p2, c.darkened(0.25), 2.0)
	# Inner red
	draw_circle(Vector2.ZERO, r * 0.5, _accent_color)
	# Face
	_draw_cute_face(r)

func _draw_strawberry(r: float, flash: float) -> void:
	var c: Color = _body_color * flash
	# Body (slightly pointed at bottom)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(20):
		var angle: float = float(i) * TAU / 20.0
		var rad: float = r * (1.0 + 0.15 * sin(angle * 2.0 - PI / 2.0))
		pts.append(Vector2(cos(angle) * rad, sin(angle) * rad))
	var clrs: PackedColorArray = PackedColorArray()
	for i: int in range(20):
		clrs.append(c)
	draw_polygon(pts, clrs)
	# Seeds
	for i: int in range(6):
		var angle: float = float(i) * TAU / 6.0 + 0.3
		var sp: Vector2 = Vector2(cos(angle), sin(angle)) * r * 0.5
		draw_circle(sp, 1.5, Color(0.9, 0.85, 0.2))
	# Leaf
	draw_circle(Vector2(0, -r * 0.7), r * 0.35, _accent_color)
	# Face
	_draw_cute_face(r)

func _draw_orange(r: float, flash: float) -> void:
	var c: Color = _body_color * flash
	draw_circle(Vector2.ZERO, r, c)
	# Highlight
	draw_circle(Vector2(-r * 0.25, -r * 0.25), r * 0.35, c.lightened(0.25))
	# Navel
	draw_circle(Vector2(0, r * 0.3), r * 0.12, c.darkened(0.2))
	# Stem
	draw_line(Vector2(0, -r), Vector2(0, -r - 5), Color(0.4, 0.3, 0.1), 2.0)
	draw_circle(Vector2(2, -r - 3), 3.0, _accent_color.darkened(0.2))
	# Face
	_draw_cute_face(r)

func _draw_grape(r: float, flash: float) -> void:
	var c: Color = _body_color * flash
	# Cluster of grapes
	var offsets: Array[Vector2] = [
		Vector2(0, 0), Vector2(-r * 0.45, -r * 0.3),
		Vector2(r * 0.45, -r * 0.3), Vector2(-r * 0.25, r * 0.35),
		Vector2(r * 0.25, r * 0.35), Vector2(0, -r * 0.55),
	]
	for off: Vector2 in offsets:
		draw_circle(off, r * 0.38, c)
		draw_circle(off + Vector2(-r * 0.08, -r * 0.08), r * 0.12, c.lightened(0.3))
	# Stem
	draw_line(Vector2(0, -r * 0.6), Vector2(0, -r - 3), Color(0.35, 0.2, 0.1), 2.0)
	# Face on center grape
	_draw_cute_face(r * 0.6)

func _draw_pineapple(r: float, flash: float) -> void:
	var c: Color = _body_color * flash
	# Body (rectangle-ish)
	var body_pts: PackedVector2Array = PackedVector2Array([
		Vector2(-r * 0.7, -r * 0.6),
		Vector2(r * 0.7, -r * 0.6),
		Vector2(r * 0.6, r * 0.8),
		Vector2(-r * 0.6, r * 0.8),
	])
	var body_clrs: PackedColorArray = PackedColorArray([c, c, c.darkened(0.15), c.darkened(0.15)])
	draw_polygon(body_pts, body_clrs)
	# Diamond pattern
	for row: int in range(3):
		for col: int in range(3):
			var dx: float = -r * 0.35 + float(col) * r * 0.35
			var dy: float = -r * 0.35 + float(row) * r * 0.4
			draw_line(Vector2(dx - 4, dy), Vector2(dx + 4, dy), c.darkened(0.25), 1.0)
			draw_line(Vector2(dx, dy - 4), Vector2(dx, dy + 4), c.darkened(0.25), 1.0)
	# Crown leaves
	for i: int in range(5):
		var lx: float = -r * 0.4 + float(i) * r * 0.2
		var sway: float = sin(_anim_time * 2.0 + float(i)) * 2.0
		draw_line(Vector2(lx, -r * 0.6), Vector2(lx + sway, -r * 1.2), _accent_color, 2.5)
	# Face
	_draw_cute_face(r * 0.7)

func _draw_cute_face(r: float) -> void:
	# Eyes
	var eye_y: float = -r * 0.1
	var eye_x: float = r * 0.25
	var blink: bool = fmod(_anim_time, 3.0) < 0.15
	if blink:
		draw_line(Vector2(-eye_x - 2, eye_y), Vector2(-eye_x + 2, eye_y), Color.BLACK, 1.5)
		draw_line(Vector2(eye_x - 2, eye_y), Vector2(eye_x + 2, eye_y), Color.BLACK, 1.5)
	else:
		draw_circle(Vector2(-eye_x, eye_y), 3.0, Color.WHITE)
		draw_circle(Vector2(eye_x, eye_y), 3.0, Color.WHITE)
		draw_circle(Vector2(-eye_x + 0.5, eye_y + 0.5), 1.5, Color(0.15, 0.1, 0.1))
		draw_circle(Vector2(eye_x + 0.5, eye_y + 0.5), 1.5, Color(0.15, 0.1, 0.1))
		# Eye highlights
		draw_circle(Vector2(-eye_x - 0.8, eye_y - 0.8), 0.8, Color.WHITE)
		draw_circle(Vector2(eye_x - 0.8, eye_y - 0.8), 0.8, Color.WHITE)
	# Mouth
	draw_arc(Vector2(0, r * 0.15), r * 0.15, 0.2, PI - 0.2, 8, Color(0.15, 0.1, 0.1), 1.5)
	# Blush
	draw_circle(Vector2(-eye_x - 3, r * 0.15), 2.5, Color(1.0, 0.5, 0.5, 0.4))
	draw_circle(Vector2(eye_x + 3, r * 0.15), 2.5, Color(1.0, 0.5, 0.5, 0.4))
