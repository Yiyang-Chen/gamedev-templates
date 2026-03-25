class_name TDEnemy extends Node2D

## A single enemy that follows the path and can be damaged.

var enemy_type: int = TDGameData.EnemyType.ANT
var max_hp: float = 30.0
var current_hp: float = 30.0
var move_speed: float = 60.0
var reward: int = 5
var enemy_size: float = 1.0

var path_points: Array[Vector2] = []
var current_path_index: int = 0
var reached_end: bool = false
var is_dead: bool = false

var slow_factor: float = 1.0
var slow_timer: float = 0.0

var _body_color: Color = Color.BLACK
var _eye_color: Color = Color.WHITE
var _anim_time: float = 0.0

signal enemy_killed(enemy: TDEnemy)
signal enemy_reached_end(enemy: TDEnemy)

func setup(et: int, path: Array[Vector2], hp_mult: float = 1.0, speed_mult: float = 1.0) -> void:
	enemy_type = et
	path_points = path
	var stats: TDGameData.EnemyStats = TDGameData.get_enemy_stats(et)
	max_hp = stats.max_hp * hp_mult
	current_hp = max_hp
	move_speed = stats.speed * speed_mult
	reward = stats.reward
	enemy_size = stats.size
	_body_color = TDGameData.ENEMY_COLORS[et]
	
	if path_points.size() > 0:
		position = path_points[0]
		current_path_index = 1

func take_damage(amount: float) -> void:
	if is_dead:
		return
	current_hp -= amount
	if current_hp <= 0.0:
		current_hp = 0.0
		is_dead = true
		enemy_killed.emit(self)

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = minf(slow_factor, factor)
	slow_timer = maxf(slow_timer, duration)

func _process(delta: float) -> void:
	if is_dead or reached_end:
		return

	_anim_time += delta

	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_factor = 1.0

	if current_path_index >= path_points.size():
		reached_end = true
		enemy_reached_end.emit(self)
		return

	var target: Vector2 = path_points[current_path_index]
	var dir: Vector2 = (target - position)
	var dist: float = dir.length()
	var step: float = move_speed * slow_factor * delta

	if step >= dist:
		position = target
		current_path_index += 1
	else:
		position += dir.normalized() * step

	queue_redraw()

func _draw() -> void:
	var s: float = enemy_size
	var r: float = 10.0 * s

	# Shadow
	draw_circle(Vector2(2, 3), r, Color(0, 0, 0, 0.2))

	match enemy_type:
		TDGameData.EnemyType.ANT:
			_draw_ant(r, s)
		TDGameData.EnemyType.CATERPILLAR:
			_draw_caterpillar(r, s)
		TDGameData.EnemyType.BEETLE:
			_draw_beetle(r, s)
		TDGameData.EnemyType.LOCUST:
			_draw_locust(r, s)
		TDGameData.EnemyType.BOSS_SPIDER:
			_draw_spider(r, s)

	# HP bar
	if current_hp < max_hp:
		var bar_w: float = 24.0 * s
		var bar_h: float = 3.0
		var bar_y: float = -r - 6.0
		draw_rect(Rect2(-bar_w / 2.0, bar_y, bar_w, bar_h), Color(0.2, 0.2, 0.2, 0.8))
		var hp_ratio: float = current_hp / max_hp
		var hp_color: Color = Color(0.2, 0.8, 0.2) if hp_ratio > 0.5 else (Color(0.9, 0.7, 0.1) if hp_ratio > 0.25 else Color(0.9, 0.2, 0.2))
		draw_rect(Rect2(-bar_w / 2.0, bar_y, bar_w * hp_ratio, bar_h), hp_color)

	# Slow indicator
	if slow_timer > 0.0:
		draw_circle(Vector2(0, -r - 10.0), 2.5, Color(0.3, 0.6, 1.0, 0.8))

func _draw_ant(r: float, s: float) -> void:
	draw_circle(Vector2.ZERO, r, _body_color)
	draw_circle(Vector2(-r * 0.7, 0), r * 0.6, _body_color.lightened(0.1))
	# Eyes
	draw_circle(Vector2(r * 0.3, -r * 0.3), 2.0 * s, _eye_color)
	draw_circle(Vector2(r * 0.3, r * 0.3), 2.0 * s, _eye_color)
	draw_circle(Vector2(r * 0.35, -r * 0.3), 1.0 * s, Color.BLACK)
	draw_circle(Vector2(r * 0.35, r * 0.3), 1.0 * s, Color.BLACK)
	# Legs
	for i: int in range(3):
		var lx: float = -r * 0.3 + float(i) * r * 0.4
		draw_line(Vector2(lx, -r * 0.5), Vector2(lx - 3.0 * s, -r - 2.0 * s), _body_color.darkened(0.2), 1.5)
		draw_line(Vector2(lx, r * 0.5), Vector2(lx - 3.0 * s, r + 2.0 * s), _body_color.darkened(0.2), 1.5)

func _draw_caterpillar(r: float, s: float) -> void:
	var segments: int = 4
	for i: int in range(segments):
		var ox: float = -float(i) * r * 0.7
		var wiggle: float = sin(_anim_time * 3.0 + float(i) * 0.8) * 2.0
		var seg_color: Color = _body_color.lightened(0.05 * float(i))
		draw_circle(Vector2(ox, wiggle), r * 0.65, seg_color)
	draw_circle(Vector2(r * 0.3, 0), r * 0.7, _body_color.lightened(0.15))
	draw_circle(Vector2(r * 0.5, -r * 0.25), 2.0 * s, _eye_color)
	draw_circle(Vector2(r * 0.5, r * 0.25), 2.0 * s, _eye_color)
	draw_circle(Vector2(r * 0.55, -r * 0.25), 1.0 * s, Color.BLACK)
	draw_circle(Vector2(r * 0.55, r * 0.25), 1.0 * s, Color.BLACK)

func _draw_beetle(r: float, s: float) -> void:
	draw_circle(Vector2.ZERO, r, _body_color)
	# Shell
	draw_arc(Vector2.ZERO, r * 0.9, -PI * 0.8, PI * 0.8, 20, _body_color.lightened(0.2), 2.0 * s)
	draw_line(Vector2(-r * 0.8, 0), Vector2(r * 0.6, 0), _body_color.lightened(0.15), 1.5 * s)
	# Shield highlight
	draw_circle(Vector2(-r * 0.2, -r * 0.2), r * 0.25, _body_color.lightened(0.3))
	# Eyes
	draw_circle(Vector2(r * 0.4, -r * 0.35), 2.5 * s, _eye_color)
	draw_circle(Vector2(r * 0.4, r * 0.35), 2.5 * s, _eye_color)
	draw_circle(Vector2(r * 0.45, -r * 0.35), 1.2 * s, Color.BLACK)
	draw_circle(Vector2(r * 0.45, r * 0.35), 1.2 * s, Color.BLACK)

func _draw_locust(r: float, s: float) -> void:
	# Body
	var pts: PackedVector2Array = PackedVector2Array([
		Vector2(r * 0.8, 0),
		Vector2(0, -r * 0.5),
		Vector2(-r, 0),
		Vector2(0, r * 0.5),
	])
	var colors: PackedColorArray = PackedColorArray([_body_color, _body_color, _body_color.darkened(0.2), _body_color])
	draw_polygon(pts, colors)
	# Wings
	var wing_y: float = sin(_anim_time * 8.0) * 3.0 * s
	draw_line(Vector2(-r * 0.2, -r * 0.4), Vector2(-r * 0.1, -r - wing_y), _body_color.lightened(0.3), 1.5 * s)
	draw_line(Vector2(-r * 0.2, r * 0.4), Vector2(-r * 0.1, r + wing_y), _body_color.lightened(0.3), 1.5 * s)
	# Eyes
	draw_circle(Vector2(r * 0.5, -r * 0.15), 2.0 * s, _eye_color)
	draw_circle(Vector2(r * 0.5, r * 0.15), 2.0 * s, _eye_color)

func _draw_spider(r: float, s: float) -> void:
	draw_circle(Vector2.ZERO, r, _body_color)
	draw_circle(Vector2(r * 0.6, 0), r * 0.7, _body_color.lightened(0.1))
	# 8 legs
	for i: int in range(4):
		var angle_top: float = -PI * 0.2 - float(i) * 0.35
		var angle_bot: float = PI * 0.2 + float(i) * 0.35
		var leg_len: float = r * 1.5 + sin(_anim_time * 4.0 + float(i)) * 2.0
		draw_line(Vector2.ZERO, Vector2(cos(angle_top) * leg_len, sin(angle_top) * leg_len), _body_color.darkened(0.1), 2.0 * s)
		draw_line(Vector2.ZERO, Vector2(cos(angle_bot) * leg_len, sin(angle_bot) * leg_len), _body_color.darkened(0.1), 2.0 * s)
	# Eyes (multiple, spider-like)
	for j: int in range(4):
		var ex: float = r * 0.7 + float(j % 2) * r * 0.2
		var ey: float = -r * 0.3 + float(j) * r * 0.15
		draw_circle(Vector2(ex, ey), 2.5 * s, Color(0.9, 0.1, 0.1))
		draw_circle(Vector2(ex + 0.5, ey), 1.2 * s, Color.BLACK)
