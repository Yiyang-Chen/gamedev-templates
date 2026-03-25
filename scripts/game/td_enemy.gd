class_name TDEnemy extends Node2D
## Enemy bug that follows the waypoint path


signal enemy_reached_end(enemy: TDEnemy)
signal enemy_died(enemy: TDEnemy)


var enemy_type: int = 0
var max_hp: float = 1.0
var current_hp: float = 1.0
var speed: float = 50.0
var reward: int = 10
var body_size: float = 11.0
var body_color: Color = Color.GREEN
var highlight_color: Color = Color.LIGHT_GREEN

var _waypoints: Array = []
var _waypoint_idx: int = 0
var _slow_timer: float = 0.0
var _slow_factor: float = 1.0
var _dead: bool = false
var _leg_anim: float = 0.0
var _eye_blink: float = 0.0
var _wave_multiplier: float = 1.0


func setup(type: int, waypoints: Array, wave: int) -> void:
	enemy_type = type
	max_hp = TDData.ENEMY_HPS[type] as float
	speed = TDData.ENEMY_SPEEDS[type] as float
	reward = TDData.ENEMY_REWARDS[type] as int
	body_size = TDData.ENEMY_SIZES[type] as float
	body_color = TDData.ENEMY_BODY_COLORS[type] as Color
	highlight_color = TDData.ENEMY_HIGHLIGHT_COLORS[type] as Color
	_wave_multiplier = 1.0 + float(wave) * 0.15
	max_hp *= _wave_multiplier
	current_hp = max_hp
	_waypoints = waypoints.duplicate()
	if _waypoints.size() > 0:
		position = _waypoints[0] as Vector2
	_waypoint_idx = 1


func take_damage(amount: float) -> void:
	if _dead:
		return
	current_hp -= amount
	if current_hp <= 0.0:
		current_hp = 0.0
		_dead = true
		enemy_died.emit(self)
		queue_free()


func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = factor
	_slow_timer = duration


func _process(delta: float) -> void:
	if _dead:
		return
	if _waypoint_idx >= _waypoints.size():
		enemy_reached_end.emit(self)
		queue_free()
		return

	var spd: float = speed
	if _slow_timer > 0.0:
		_slow_timer -= delta
		spd *= _slow_factor
	else:
		_slow_factor = 1.0

	var target: Vector2 = _waypoints[_waypoint_idx] as Vector2
	var dir: Vector2 = target - position
	var dist: float = dir.length()
	var step: float = spd * delta

	if step >= dist:
		position = target
		_waypoint_idx += 1
	else:
		position += dir.normalized() * step

	_leg_anim += delta * 8.0
	_eye_blink += delta
	queue_redraw()


func _draw() -> void:
	var s: float = body_size

	var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.2)
	draw_circle(Vector2(2.0, 4.0), s + 2.0, shadow_color)

	match enemy_type:
		0:
			_draw_caterpillar(s)
		1:
			_draw_aphid(s)
		2:
			_draw_beetle(s)
		3:
			_draw_fly(s)
		4:
			_draw_slug(s)

	var hp_pct: float = current_hp / max_hp
	var bar_w: float = s * 2.5
	var bar_y: float = -s - 8.0
	draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w, 4.0), Color(0.2, 0.2, 0.2, 0.8))
	var hp_color: Color = Color.GREEN if hp_pct > 0.5 else (Color.YELLOW if hp_pct > 0.25 else Color.RED)
	draw_rect(Rect2(-bar_w * 0.5, bar_y, bar_w * hp_pct, 4.0), hp_color)

	if _slow_timer > 0.0:
		draw_circle(Vector2(0.0, -s - 14.0), 3.0, Color(0.3, 0.5, 1.0, 0.8))


func _draw_caterpillar(s: float) -> void:
	var seg_count: int = 4
	for i: int in range(seg_count):
		var off_x: float = -float(seg_count - 1 - i) * s * 0.7
		var bounce: float = sin(_leg_anim + float(i) * 1.5) * 2.0
		var seg_s: float = s * (0.7 + float(i) * 0.1)
		draw_circle(Vector2(off_x, bounce), seg_s, body_color)
		draw_circle(Vector2(off_x - seg_s * 0.15, bounce - seg_s * 0.2), seg_s * 0.3, highlight_color)
	_draw_cute_face(Vector2(0.0, 0.0), s)


func _draw_aphid(s: float) -> void:
	draw_circle(Vector2.ZERO, s, body_color)
	draw_circle(Vector2(-s * 0.15, -s * 0.2), s * 0.4, highlight_color)
	var wing_c: Color = Color(1.0, 1.0, 1.0, 0.5)
	var wobble: float = sin(_leg_anim) * 5.0
	draw_circle(Vector2(-s * 0.5, -s + wobble), s * 0.5, wing_c)
	draw_circle(Vector2(s * 0.5, -s + wobble), s * 0.5, wing_c)
	_draw_cute_face(Vector2.ZERO, s * 0.8)


func _draw_beetle(s: float) -> void:
	draw_circle(Vector2.ZERO, s, body_color)
	draw_arc(Vector2.ZERO, s, 0.0, PI, 20, Color(0.3, 0.2, 0.1), 2.0)
	draw_circle(Vector2(-s * 0.15, -s * 0.2), s * 0.3, highlight_color)
	var shell_dark: Color = body_color.darkened(0.3)
	draw_line(Vector2(0.0, -s), Vector2(0.0, s), shell_dark, 1.5)
	for i: int in range(3):
		var ly: float = -s * 0.3 + float(i) * s * 0.4
		var lx: float = sin(_leg_anim + float(i)) * 3.0
		draw_line(Vector2(-s, ly), Vector2(-s - 5.0 + lx, ly + 2.0), shell_dark, 1.5)
		draw_line(Vector2(s, ly), Vector2(s + 5.0 - lx, ly + 2.0), shell_dark, 1.5)
	_draw_cute_face(Vector2(0.0, -s * 0.15), s * 0.7)


func _draw_fly(s: float) -> void:
	draw_circle(Vector2.ZERO, s, body_color)
	draw_circle(Vector2(-s * 0.15, -s * 0.2), s * 0.35, highlight_color)
	var wing_c: Color = Color(0.8, 0.9, 1.0, 0.4)
	var wb: float = sin(_leg_anim * 2.0) * 8.0
	draw_circle(Vector2(-s * 0.8, -s * 0.5 + wb), s * 0.65, wing_c)
	draw_circle(Vector2(s * 0.8, -s * 0.5 - wb), s * 0.65, wing_c)
	_draw_cute_face(Vector2.ZERO, s * 0.8)


func _draw_slug(s: float) -> void:
	var trail_alpha: float = 0.15
	for i: int in range(5):
		var tx: float = -float(i) * s * 0.5
		draw_circle(Vector2(tx, s * 0.3), 3.0, Color(0.6, 0.3, 0.8, trail_alpha))

	draw_circle(Vector2.ZERO, s, body_color)
	draw_circle(Vector2(0.0, -s * 0.4), s * 0.75, highlight_color)
	draw_circle(Vector2(-s * 0.15, -s * 0.5), s * 0.2, Color(1.0, 1.0, 1.0, 0.5))

	draw_line(Vector2(-s * 0.3, -s), Vector2(-s * 0.5, -s - 8.0), body_color, 2.0)
	draw_circle(Vector2(-s * 0.5, -s - 8.0), 2.0, body_color)
	draw_line(Vector2(s * 0.3, -s), Vector2(s * 0.5, -s - 8.0), body_color, 2.0)
	draw_circle(Vector2(s * 0.5, -s - 8.0), 2.0, body_color)

	_draw_cute_face(Vector2(0.0, -s * 0.15), s * 0.8)


func _draw_cute_face(center: Vector2, face_s: float) -> void:
	var eye_sep: float = face_s * 0.35
	var eye_r: float = face_s * 0.22
	var pupil_r: float = eye_r * 0.5
	var blink: bool = fmod(_eye_blink, 3.5) < 0.15

	if blink:
		draw_line(center + Vector2(-eye_sep, 0.0) + Vector2(-eye_r, 0.0),
			center + Vector2(-eye_sep, 0.0) + Vector2(eye_r, 0.0),
			Color.BLACK, 1.5)
		draw_line(center + Vector2(eye_sep, 0.0) + Vector2(-eye_r, 0.0),
			center + Vector2(eye_sep, 0.0) + Vector2(eye_r, 0.0),
			Color.BLACK, 1.5)
	else:
		draw_circle(center + Vector2(-eye_sep, 0.0), eye_r, Color.WHITE)
		draw_circle(center + Vector2(-eye_sep, 0.0), pupil_r, Color.BLACK)
		draw_circle(center + Vector2(-eye_sep, 0.0) + Vector2(-1.0, -1.0), pupil_r * 0.3, Color.WHITE)

		draw_circle(center + Vector2(eye_sep, 0.0), eye_r, Color.WHITE)
		draw_circle(center + Vector2(eye_sep, 0.0), pupil_r, Color.BLACK)
		draw_circle(center + Vector2(eye_sep, 0.0) + Vector2(-1.0, -1.0), pupil_r * 0.3, Color.WHITE)

	var mouth_y: float = center.y + face_s * 0.32
	draw_arc(center + Vector2(0.0, mouth_y - center.y), face_s * 0.18,
		0.2, PI - 0.2, 8, Color(0.15, 0.1, 0.1), 1.5)

	var cheek_c: Color = Color(1.0, 0.5, 0.5, 0.4)
	draw_circle(center + Vector2(-eye_sep - face_s * 0.15, face_s * 0.2), face_s * 0.12, cheek_c)
	draw_circle(center + Vector2(eye_sep + face_s * 0.15, face_s * 0.2), face_s * 0.12, cheek_c)
