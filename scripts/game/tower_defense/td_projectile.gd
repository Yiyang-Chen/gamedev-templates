class_name TDProjectile extends Node2D

## A projectile fired by a tower at an enemy.

var target: TDEnemy = null
var tower_type: int = TDGameData.TowerType.WATERMELON
var damage: float = 10.0
var speed: float = 300.0
var _color: Color = Color.BLACK
var _size: float = 4.0

## Watermelon/Orange: splash radius; Strawberry: slow factor; Pineapple: pierce count
var special_value: float = 0.0
## Strawberry slow duration
var slow_duration: float = 2.0

## Pineapple: track already hit enemies
var _hit_enemies: Array[TDEnemy] = []
var _direction: Vector2 = Vector2.RIGHT
var _max_range: float = 400.0
var _distance_traveled: float = 0.0

signal projectile_finished(proj: TDProjectile)

func setup(t: TDEnemy, tt: int, dmg: float, sv: float) -> void:
	target = t
	tower_type = tt
	damage = dmg
	special_value = sv
	_color = TDGameData.TOWER_PROJECTILE_COLORS[tt]

	match tt:
		TDGameData.TowerType.WATERMELON:
			_size = 5.0
			speed = 280.0
		TDGameData.TowerType.STRAWBERRY:
			_size = 4.0
			speed = 320.0
			slow_duration = 2.0
		TDGameData.TowerType.ORANGE:
			_size = 7.0
			speed = 220.0
		TDGameData.TowerType.GRAPE:
			_size = 3.0
			speed = 400.0
		TDGameData.TowerType.PINEAPPLE:
			_size = 6.0
			speed = 250.0
			_max_range = special_value * 60.0
			if target:
				_direction = (target.position - position).normalized()

	if target and is_instance_valid(target):
		_direction = (target.position - position).normalized()

func _process(delta: float) -> void:
	if tower_type == TDGameData.TowerType.PINEAPPLE:
		_process_piercing(delta)
		return

	if target == null or not is_instance_valid(target) or target.is_dead:
		_destroy()
		return

	var to_target: Vector2 = target.position - position
	var dist: float = to_target.length()

	if dist < 8.0:
		_on_hit_target()
		return

	_direction = to_target.normalized()
	position += _direction * speed * delta
	_distance_traveled += speed * delta

	if _distance_traveled > 800.0:
		_destroy()
		return

	queue_redraw()

func _process_piercing(delta: float) -> void:
	position += _direction * speed * delta
	_distance_traveled += speed * delta

	if _distance_traveled > _max_range:
		_destroy()
		return

	# Check collisions with all enemies in range
	var enemies_node: Node = get_parent()
	if enemies_node == null:
		_destroy()
		return

	for child: Node in enemies_node.get_children():
		if child is TDEnemy:
			@warning_ignore("unsafe_cast")
			var enemy: TDEnemy = child as TDEnemy
			if enemy.is_dead or _hit_enemies.has(enemy):
				continue
			if position.distance_to(enemy.position) < 15.0:
				enemy.take_damage(damage)
				_hit_enemies.append(enemy)

	queue_redraw()

func _on_hit_target() -> void:
	match tower_type:
		TDGameData.TowerType.WATERMELON:
			_splash_damage(special_value)
		TDGameData.TowerType.STRAWBERRY:
			target.take_damage(damage)
			target.apply_slow(special_value, slow_duration)
		TDGameData.TowerType.ORANGE:
			_splash_damage(special_value)
		TDGameData.TowerType.GRAPE:
			target.take_damage(damage)
		_:
			target.take_damage(damage)

	_destroy()

func _splash_damage(radius: float) -> void:
	var enemies_node: Node = get_parent()
	if enemies_node == null:
		if target and is_instance_valid(target):
			target.take_damage(damage)
		return

	for child: Node in enemies_node.get_children():
		if child is TDEnemy:
			@warning_ignore("unsafe_cast")
			var enemy: TDEnemy = child as TDEnemy
			if enemy.is_dead:
				continue
			if position.distance_to(enemy.position) <= radius:
				var dist_ratio: float = 1.0 - (position.distance_to(enemy.position) / radius) * 0.5
				enemy.take_damage(damage * dist_ratio)

func _destroy() -> void:
	projectile_finished.emit(self)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _size, _color)
	draw_circle(Vector2(-_size * 0.3, -_size * 0.3), _size * 0.3, _color.lightened(0.4))
