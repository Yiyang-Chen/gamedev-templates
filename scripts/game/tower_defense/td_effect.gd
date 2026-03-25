class_name TDEffect extends Node2D

## Simple visual effect node that auto-destroys after animation.

var _particles: Array[Dictionary] = []
var _lifetime: float = 0.0
var _max_lifetime: float = 0.5

func spawn_death_effect(pos: Vector2, col: Color, count: int = 6) -> void:
	position = pos
	_max_lifetime = 0.6
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	for i: int in range(count):
		var angle: float = rng.randf() * TAU
		var spd: float = rng.randf_range(30.0, 80.0)
		var sz: float = rng.randf_range(2.0, 5.0)
		var particle: Dictionary = {
			"x": 0.0,
			"y": 0.0,
			"vx": cos(angle) * spd,
			"vy": sin(angle) * spd,
			"size": sz,
			"color": col.lightened(rng.randf_range(0.0, 0.3)),
		}
		_particles.append(particle)

func spawn_coin_effect(pos: Vector2) -> void:
	position = pos
	_max_lifetime = 0.4
	var particle: Dictionary = {
		"x": 0.0,
		"y": 0.0,
		"vx": 0.0,
		"vy": -40.0,
		"size": 6.0,
		"color": Color(1.0, 0.85, 0.1),
	}
	_particles.append(particle)

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		queue_free()
		return

	for p: Dictionary in _particles:
		p["x"] = float(p["x"]) + float(p["vx"]) * delta
		p["y"] = float(p["y"]) + float(p["vy"]) * delta
		p["vy"] = float(p["vy"]) + 60.0 * delta

	queue_redraw()

func _draw() -> void:
	var alpha_ratio: float = 1.0 - (_lifetime / _max_lifetime)
	for p: Dictionary in _particles:
		@warning_ignore("unsafe_cast")
		var px: float = p["x"] as float
		@warning_ignore("unsafe_cast")
		var py: float = p["y"] as float
		@warning_ignore("unsafe_cast")
		var sz: float = p["size"] as float
		@warning_ignore("unsafe_cast")
		var col: Color = p["color"] as Color
		col.a = alpha_ratio
		draw_circle(Vector2(px, py), sz * alpha_ratio, col)
