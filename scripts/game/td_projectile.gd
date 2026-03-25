class_name TDProjectile extends Node2D
## Projectile fired by fruit towers at enemies


var target: TDEnemy = null
var damage: float = 10.0
var speed: float = 400.0
var atk_type: int = TDData.ATK_SINGLE
var splash_radius: float = 0.0
var slow_factor: float = 0.0
var tower_type: int = 0
var _trail: Array = []
var _enemy_layer: Node2D = null
var _alive: bool = true


func setup(t: TDTower, tgt: TDEnemy, el: Node2D) -> void:
	tower_type = t.tower_type
	damage = t.get_damage()
	speed = TDData.TOWER_PROJ_SPEEDS[t.tower_type] as float
	atk_type = TDData.TOWER_ATK_TYPES[t.tower_type] as int
	splash_radius = TDData.TOWER_SPLASH_R[t.tower_type] as float
	slow_factor = TDData.TOWER_SLOW_F[t.tower_type] as float
	target = tgt
	_enemy_layer = el
	position = t.position


func _process(delta: float) -> void:
	if not _alive:
		return

	if not is_instance_valid(target):
		_alive = false
		queue_free()
		return

	var dir: Vector2 = target.position - position
	var dist: float = dir.length()
	var step: float = speed * delta

	_trail.push_back(Vector2(position.x, position.y))
	if _trail.size() > 6:
		_trail.pop_front()

	if step >= dist:
		position = target.position
		_hit()
	else:
		position += dir.normalized() * step

	queue_redraw()


func _hit() -> void:
	_alive = false

	match atk_type:
		TDData.ATK_SINGLE:
			if is_instance_valid(target):
				target.take_damage(damage)
		TDData.ATK_SPLASH:
			_splash_damage()
		TDData.ATK_SLOW:
			if is_instance_valid(target):
				target.take_damage(damage)
				target.apply_slow(slow_factor, 1.5)
		TDData.ATK_SNIPER:
			if is_instance_valid(target):
				target.take_damage(damage)

	queue_free()


func _splash_damage() -> void:
	if _enemy_layer == null:
		return
	for child: Node in _enemy_layer.get_children():
		var enemy: TDEnemy = child as TDEnemy
		if enemy == null:
			continue
		if position.distance_to(enemy.position) <= splash_radius:
			enemy.take_damage(damage)


func _draw() -> void:
	var proj_c: Color = TDData.TOWER_BODY_COLORS[tower_type] as Color
	var size: float = 5.0

	for i: int in range(_trail.size()):
		var tp: Vector2 = _trail[i] as Vector2
		var local_p: Vector2 = tp - position
		var alpha: float = float(i) / float(_trail.size()) * 0.4
		draw_circle(local_p, size * 0.4, Color(proj_c.r, proj_c.g, proj_c.b, alpha))

	draw_circle(Vector2.ZERO, size, proj_c)
	draw_circle(Vector2(-1.5, -1.5), size * 0.35, Color(1.0, 1.0, 1.0, 0.7))
