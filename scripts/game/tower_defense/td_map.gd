class_name TDMap extends Node2D

## Renders the tower defense map with grass, path, and buildable tiles.

var _layout: Array[Array] = []
var _decoration_seed: int = 42

func setup() -> void:
	_layout = TDGameData.get_map_layout()
	_decoration_seed = 42
	queue_redraw()

func get_cell_type(col: int, row: int) -> int:
	if row < 0 or row >= _layout.size() or col < 0:
		return TDGameData.CellType.BLOCKED
	var map_row: Array = _layout[row]
	if col >= map_row.size():
		return TDGameData.CellType.BLOCKED
	return map_row[col]

func is_buildable(col: int, row: int) -> bool:
	var ct: int = get_cell_type(col, row)
	return ct == TDGameData.CellType.BUILDABLE or ct == TDGameData.CellType.PATH

func cell_to_world(col: int, row: int) -> Vector2:
	return Vector2(
		col * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2,
		row * TDGameData.TILE_SIZE + TDGameData.TILE_SIZE / 2
	)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	@warning_ignore("narrowing_conversion")
	var col: int = int(world_pos.x / float(TDGameData.TILE_SIZE))
	@warning_ignore("narrowing_conversion")
	var row: int = int(world_pos.y / float(TDGameData.TILE_SIZE))
	return Vector2i(col, row)

func _draw() -> void:
	var ts: float = float(TDGameData.TILE_SIZE)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _decoration_seed

	for row: int in range(_layout.size()):
		var map_row: Array = _layout[row]
		for col: int in range(map_row.size()):
			var cell: int = map_row[col]
			var rect: Rect2 = Rect2(float(col) * ts, float(row) * ts, ts, ts)

			match cell:
				TDGameData.CellType.GRASS:
					_draw_grass(rect, rng)
				TDGameData.CellType.PATH:
					_draw_path_tile(rect, col, row)
				TDGameData.CellType.BUILDABLE:
					_draw_buildable(rect, rng)
				TDGameData.CellType.BLOCKED:
					_draw_grass(rect, rng)
					_draw_decoration(rect, rng)
				TDGameData.CellType.START:
					_draw_path_tile(rect, col, row)
					_draw_start_marker(rect)
				TDGameData.CellType.END:
					_draw_path_tile(rect, col, row)
					_draw_end_marker(rect)

func _draw_grass(rect: Rect2, rng: RandomNumberGenerator) -> void:
	var base: Color = Color(0.35, 0.72, 0.28)
	var variation: float = rng.randf_range(-0.04, 0.04)
	draw_rect(rect, Color(base.r + variation, base.g + variation * 0.5, base.b + variation))
	# Grass tufts
	for i: int in range(2):
		var gx: float = rect.position.x + rng.randf_range(8, rect.size.x - 8)
		var gy: float = rect.position.y + rng.randf_range(8, rect.size.y - 8)
		var gc: Color = base.lightened(rng.randf_range(0.05, 0.15))
		draw_circle(Vector2(gx, gy), rng.randf_range(1.5, 3.0), gc)

func _draw_path_tile(rect: Rect2, col: int, row: int) -> void:
	var path_color: Color = Color(0.82, 0.72, 0.55)
	draw_rect(rect, path_color)
	# Path borders
	var border_color: Color = path_color.darkened(0.15)
	var bw: float = 2.0
	# Check adjacency for borders
	if not _is_path_cell(col, row - 1):
		draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, bw), border_color)
	if not _is_path_cell(col, row + 1):
		draw_rect(Rect2(rect.position.x, rect.position.y + rect.size.y - bw, rect.size.x, bw), border_color)
	if not _is_path_cell(col - 1, row):
		draw_rect(Rect2(rect.position.x, rect.position.y, bw, rect.size.y), border_color)
	if not _is_path_cell(col + 1, row):
		draw_rect(Rect2(rect.position.x + rect.size.x - bw, rect.position.y, bw, rect.size.y), border_color)
	# Subtle texture dots
	var cx: float = rect.position.x + rect.size.x * 0.5
	var cy: float = rect.position.y + rect.size.y * 0.5
	draw_circle(Vector2(cx - 8, cy + 5), 1.5, path_color.darkened(0.08))
	draw_circle(Vector2(cx + 10, cy - 3), 1.0, path_color.darkened(0.06))

func _is_path_cell(col: int, row: int) -> bool:
	var ct: int = get_cell_type(col, row)
	return ct == TDGameData.CellType.PATH or ct == TDGameData.CellType.START or ct == TDGameData.CellType.END

func _draw_buildable(rect: Rect2, rng: RandomNumberGenerator) -> void:
	var base: Color = Color(0.42, 0.75, 0.35)
	var variation: float = rng.randf_range(-0.03, 0.03)
	draw_rect(rect, Color(base.r + variation, base.g + variation, base.b + variation))
	# Dashed border to show it's buildable
	var dash_color: Color = Color(1, 1, 1, 0.2)
	draw_rect(Rect2(rect.position.x + 2, rect.position.y + 2, rect.size.x - 4, rect.size.y - 4), dash_color, false, 1.0)

func _draw_decoration(rect: Rect2, rng: RandomNumberGenerator) -> void:
	var cx: float = rect.position.x + rect.size.x * 0.5
	var cy: float = rect.position.y + rect.size.y * 0.5
	var deco_type: int = rng.randi_range(0, 2)
	match deco_type:
		0:
			# Small flower
			draw_circle(Vector2(cx, cy), 5, Color(0.9, 0.4, 0.5))
			draw_circle(Vector2(cx, cy), 2.5, Color(1.0, 0.85, 0.2))
		1:
			# Rock
			draw_circle(Vector2(cx, cy + 2), 7, Color(0.45, 0.42, 0.4))
			draw_circle(Vector2(cx - 1, cy), 6, Color(0.55, 0.52, 0.5))
		2:
			# Bush
			draw_circle(Vector2(cx, cy), 8, Color(0.25, 0.55, 0.2))
			draw_circle(Vector2(cx - 4, cy - 2), 6, Color(0.3, 0.6, 0.25))
			draw_circle(Vector2(cx + 3, cy - 1), 5, Color(0.28, 0.58, 0.22))

func _draw_start_marker(rect: Rect2) -> void:
	var cx: float = rect.position.x + rect.size.x * 0.5
	var cy: float = rect.position.y + rect.size.y * 0.5
	# Arrow pointing right
	var arrow_pts: PackedVector2Array = PackedVector2Array([
		Vector2(cx - 10, cy - 8),
		Vector2(cx + 6, cy),
		Vector2(cx - 10, cy + 8),
	])
	draw_colored_polygon(arrow_pts, Color(0.2, 0.8, 0.2, 0.6))

func _draw_end_marker(rect: Rect2) -> void:
	var cx: float = rect.position.x + rect.size.x * 0.5
	var cy: float = rect.position.y + rect.size.y * 0.5
	# Carrot/goal
	draw_circle(Vector2(cx, cy), 12, Color(1.0, 0.5, 0.15, 0.7))
	draw_circle(Vector2(cx, cy), 7, Color(1.0, 0.7, 0.3, 0.8))
	# Leaf on top
	draw_circle(Vector2(cx, cy - 10), 5, Color(0.3, 0.7, 0.2, 0.7))
