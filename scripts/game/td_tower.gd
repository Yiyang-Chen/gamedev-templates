class_name TDTower extends Node2D
## Fruit tower that targets and attacks enemies


signal tower_shot(tower: TDTower, target: TDEnemy)


var tower_type: int = 0
var level: int = 0
var grid_col: int = 0
var grid_row: int = 0
var _fire_timer: float = 0.0
var _body_bounce: float = 0.0
var _placed_anim: float = 0.0
var _shoot_flash: float = 0.0
var _enemy_layer: Node2D = null


func setup(type: int, col: int, row: int, enemy_layer: Node2D) -> void:
	tower_type = type
	grid_col = col
	grid_row = row
	_enemy_layer = enemy_layer
	position = TDData.cell_center(col, row)
	_placed_anim = 0.3


func get_range() -> float:
	return TDData.get_tower_range(tower_type, level)


func get_damage() -> float:
	return TDData.get_tower_damage(tower_type, level)


func get_atk_speed() -> float:
	return TDData.get_tower_atk_speed(tower_type, level)


func can_upgrade() -> bool:
	return level < TDData.MAX_UPGRADE


func get_upgrade_cost() -> int:
	return TDData.get_upgrade_cost(tower_type, level + 1)


func upgrade() -> void:
	if can_upgrade():
		level += 1
		_placed_anim = 0.3
		queue_redraw()


func get_sell_price() -> int:
	return TDData.get_sell_price(tower_type, level)


func _process(delta: float) -> void:
	_fire_timer += delta
	_body_bounce += delta * 3.0
	if _placed_anim > 0.0:
		_placed_anim -= delta
	if _shoot_flash > 0.0:
		_shoot_flash -= delta

	var fire_interval: float = 1.0 / get_atk_speed()
	if _fire_timer >= fire_interval:
		var target: TDEnemy = _find_target()
		if target != null:
			_fire_timer = 0.0
			_shoot_flash = 0.1
			tower_shot.emit(self, target)

	queue_redraw()


func _find_target() -> TDEnemy:
	if _enemy_layer == null:
		return null
	var best: TDEnemy = null
	var best_dist: float = get_range() + 1.0
	for child: Node in _enemy_layer.get_children():
		var enemy: TDEnemy = child as TDEnemy
		if enemy == null:
			continue
		var d: float = position.distance_to(enemy.position)
		if d <= get_range() and d < best_dist:
			best = enemy
			best_dist = d
	return best


func _draw() -> void:
	var s: float = float(TDData.CELL_SIZE) * 0.35
	var body_c: Color = TDData.TOWER_BODY_COLORS[tower_type] as Color
	var hi_c: Color = TDData.TOWER_HIGHLIGHT_COLORS[tower_type] as Color
	var accent_c: Color = TDData.TOWER_ACCENT_COLORS[tower_type] as Color

	var scale_f: float = 1.0
	if _placed_anim > 0.0:
		scale_f = 1.0 + _placed_anim * 2.0
	var bounce_y: float = sin(_body_bounce) * 1.5

	var shadow_c: Color = Color(0.0, 0.0, 0.0, 0.15)
	draw_circle(Vector2(0.0, s * 0.8), s * 0.7 * scale_f, shadow_c)

	match tower_type:
		0:
			_draw_strawberry(s * scale_f, bounce_y, body_c, hi_c, accent_c)
		1:
			_draw_watermelon(s * scale_f, bounce_y, body_c, hi_c, accent_c)
		2:
			_draw_lemon(s * scale_f, bounce_y, body_c, hi_c, accent_c)
		3:
			_draw_pineapple(s * scale_f, bounce_y, body_c, hi_c, accent_c)
		4:
			_draw_cherry(s * scale_f, bounce_y, body_c, hi_c, accent_c)

	if _shoot_flash > 0.0:
		var flash_alpha: float = _shoot_flash * 8.0
		draw_circle(Vector2(0.0, bounce_y), s * 1.5 * scale_f, Color(1.0, 1.0, 0.8, flash_alpha * 0.3))

	if level > 0:
		for i: int in range(level):
			var star_x: float = -float(level - 1) * 5.0 + float(i) * 10.0
			_draw_star(Vector2(star_x, -s * 1.6 + bounce_y), 4.0, Color(1.0, 0.85, 0.0))


func _draw_strawberry(s: float, by: float, body_c: Color, hi_c: Color, accent_c: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(16):
		var a: float = float(i) / 16.0 * TAU
		var r: float = s * (0.9 + 0.1 * sin(a * 3.0))
		pts.push_back(Vector2(cos(a) * r * 0.85, sin(a) * r + by))
	draw_colored_polygon(pts, body_c)
	draw_circle(Vector2(-s * 0.2, -s * 0.3 + by), s * 0.25, hi_c)
	draw_circle(Vector2(s * 0.12, s * 0.1 + by), 2.0, Color(1.0, 0.95, 0.3))
	draw_circle(Vector2(-s * 0.15, s * 0.25 + by), 2.0, Color(1.0, 0.95, 0.3))
	draw_circle(Vector2(s * 0.18, -s * 0.15 + by), 1.5, Color(1.0, 0.95, 0.3))
	_draw_leaf(Vector2(0.0, -s * 0.85 + by), s * 0.4, accent_c)
	_draw_fruit_face(Vector2(0.0, by), s * 0.6)


func _draw_watermelon(s: float, by: float, body_c: Color, hi_c: Color, _accent_c: Color) -> void:
	draw_circle(Vector2(0.0, by), s, body_c)
	draw_circle(Vector2(0.0, by), s * 0.8, Color(0.92, 0.35, 0.35))
	draw_circle(Vector2(-s * 0.15, -s * 0.25 + by), s * 0.2, hi_c)
	var stripe_c: Color = Color(0.15, 0.55, 0.2)
	for i: int in range(3):
		var a: float = float(i) * 0.8 - 0.8
		draw_line(Vector2(cos(a) * s * 0.4, -s * 0.8 + by),
			Vector2(cos(a) * s * 0.7, s * 0.8 + by), stripe_c, 2.0)
	_draw_fruit_face(Vector2(0.0, by), s * 0.6)


func _draw_lemon(s: float, by: float, body_c: Color, hi_c: Color, accent_c: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(16):
		var a: float = float(i) / 16.0 * TAU
		var rx: float = s * 0.75
		var ry: float = s * 0.95
		pts.push_back(Vector2(cos(a) * rx, sin(a) * ry + by))
	draw_colored_polygon(pts, body_c)
	draw_circle(Vector2(-s * 0.15, -s * 0.3 + by), s * 0.2, hi_c)
	_draw_leaf(Vector2(0.0, -s * 0.9 + by), s * 0.3, accent_c)
	_draw_fruit_face(Vector2(0.0, by), s * 0.55)


func _draw_pineapple(s: float, by: float, body_c: Color, hi_c: Color, accent_c: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(16):
		var a: float = float(i) / 16.0 * TAU
		var rx: float = s * 0.7
		var ry: float = s
		pts.push_back(Vector2(cos(a) * rx, sin(a) * ry + by))
	draw_colored_polygon(pts, body_c)
	draw_circle(Vector2(-s * 0.12, -s * 0.25 + by), s * 0.18, hi_c)

	var grid_c: Color = body_c.darkened(0.15)
	for gx: int in range(-2, 3):
		draw_line(Vector2(float(gx) * s * 0.3, -s * 0.8 + by),
			Vector2(float(gx) * s * 0.3, s * 0.8 + by), grid_c, 1.0)
	for gy: int in range(-2, 3):
		draw_line(Vector2(-s * 0.7, float(gy) * s * 0.35 + by),
			Vector2(s * 0.7, float(gy) * s * 0.35 + by), grid_c, 1.0)

	for li: int in range(3):
		var la: float = -0.4 + float(li) * 0.4
		var lp: Vector2 = Vector2(sin(la) * s * 0.2, -s * 1.0 + by)
		_draw_leaf(lp, s * 0.35, accent_c)
	_draw_fruit_face(Vector2(0.0, by), s * 0.5)


func _draw_cherry(s: float, by: float, body_c: Color, hi_c: Color, accent_c: Color) -> void:
	var off: float = s * 0.45
	draw_circle(Vector2(-off, by), s * 0.7, body_c)
	draw_circle(Vector2(-off - s * 0.12, -s * 0.12 + by), s * 0.18, hi_c)
	draw_circle(Vector2(off, by), s * 0.7, body_c)
	draw_circle(Vector2(off - s * 0.1, -s * 0.15 + by), s * 0.16, hi_c)
	draw_line(Vector2(-off, -s * 0.65 + by), Vector2(0.0, -s * 1.3 + by), accent_c, 2.0)
	draw_line(Vector2(off, -s * 0.65 + by), Vector2(0.0, -s * 1.3 + by), accent_c, 2.0)
	_draw_leaf(Vector2(0.0, -s * 1.3 + by), s * 0.3, accent_c)
	_draw_fruit_face(Vector2(-off * 0.3, by), s * 0.45)


func _draw_leaf(pos: Vector2, ls: float, c: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array([
		pos,
		pos + Vector2(-ls * 0.5, -ls * 0.8),
		pos + Vector2(0.0, -ls * 1.2),
		pos + Vector2(ls * 0.5, -ls * 0.8),
	])
	draw_colored_polygon(pts, c)


func _draw_fruit_face(center: Vector2, face_s: float) -> void:
	var eye_sep: float = face_s * 0.35
	var eye_r: float = face_s * 0.2
	var pupil_r: float = eye_r * 0.55

	draw_circle(center + Vector2(-eye_sep, -face_s * 0.05), eye_r, Color.WHITE)
	draw_circle(center + Vector2(-eye_sep, -face_s * 0.05), pupil_r, Color(0.15, 0.1, 0.1))
	draw_circle(center + Vector2(-eye_sep - 1.0, -face_s * 0.05 - 1.0), pupil_r * 0.35, Color.WHITE)

	draw_circle(center + Vector2(eye_sep, -face_s * 0.05), eye_r, Color.WHITE)
	draw_circle(center + Vector2(eye_sep, -face_s * 0.05), pupil_r, Color(0.15, 0.1, 0.1))
	draw_circle(center + Vector2(eye_sep - 1.0, -face_s * 0.05 - 1.0), pupil_r * 0.35, Color.WHITE)

	var mouth_c: Color = Color(0.15, 0.1, 0.1)
	draw_arc(center + Vector2(0.0, face_s * 0.2), face_s * 0.15,
		0.3, PI - 0.3, 8, mouth_c, 1.5)

	var blush: Color = Color(1.0, 0.5, 0.5, 0.35)
	draw_circle(center + Vector2(-eye_sep - face_s * 0.12, face_s * 0.12), face_s * 0.1, blush)
	draw_circle(center + Vector2(eye_sep + face_s * 0.12, face_s * 0.12), face_s * 0.1, blush)


func _draw_star(center: Vector2, r: float, c: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(10):
		var a: float = float(i) / 10.0 * TAU - PI / 2.0
		var sr: float = r if i % 2 == 0 else r * 0.45
		pts.push_back(center + Vector2(cos(a) * sr, sin(a) * sr))
	draw_colored_polygon(pts, c)
	draw_colored_polygon(pts, Color(1.0, 1.0, 1.0, 0.3))
