class_name TDMapRenderer extends Node2D
## Renders the grid map with paths, grass, and decorations


var _grass_details: Array = []
var _flower_positions: Array = []
var _hover_cell: Vector2i = Vector2i(-1, -1)
var _hover_valid: bool = false
var _selected_cell: Vector2i = Vector2i(-1, -1)
var _range_radius: float = 0.0


func _ready() -> void:
	_generate_decorations()


func _generate_decorations() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	for row: int in range(TDData.GRID_ROWS):
		for col: int in range(TDData.GRID_COLS):
			if TDData.is_buildable(col, row):
				for _i: int in range(rng.randi_range(1, 3)):
					var cx: float = float(col * TDData.CELL_SIZE) + rng.randf_range(8.0, float(TDData.CELL_SIZE) - 8.0)
					var cy: float = float(row * TDData.CELL_SIZE) + rng.randf_range(8.0, float(TDData.CELL_SIZE) - 8.0)
					var gs: float = rng.randf_range(2.0, 5.0)
					_grass_details.push_back(Vector3(cx, cy, gs))

				if rng.randf() < 0.12:
					var fx: float = float(col * TDData.CELL_SIZE) + rng.randf_range(12.0, float(TDData.CELL_SIZE) - 12.0)
					var fy: float = float(row * TDData.CELL_SIZE) + rng.randf_range(12.0, float(TDData.CELL_SIZE) - 12.0)
					var ftype: float = float(rng.randi_range(0, 2))
					_flower_positions.push_back(Vector3(fx, fy, ftype))


func set_hover(cell: Vector2i, valid: bool) -> void:
	_hover_cell = cell
	_hover_valid = valid
	queue_redraw()


func set_selected(cell: Vector2i, range_r: float) -> void:
	_selected_cell = cell
	_range_radius = range_r
	queue_redraw()


func clear_selection() -> void:
	_selected_cell = Vector2i(-1, -1)
	_range_radius = 0.0
	queue_redraw()


func clear_hover() -> void:
	_hover_cell = Vector2i(-1, -1)
	queue_redraw()


func _draw() -> void:
	var bg_color: Color = Color(0.42, 0.75, 0.32)
	draw_rect(Rect2(0.0, 0.0, float(TDData.GRID_COLS * TDData.CELL_SIZE),
		float(TDData.GRID_ROWS * TDData.CELL_SIZE)), bg_color)

	for row: int in range(TDData.GRID_ROWS):
		for col: int in range(TDData.GRID_COLS):
			var x: float = float(col * TDData.CELL_SIZE)
			var y: float = float(row * TDData.CELL_SIZE)
			var cs: float = float(TDData.CELL_SIZE)

			if TDData.is_path(col, row):
				_draw_path_cell(x, y, cs, col, row)
			else:
				var alt: Color = bg_color.lightened(0.03) if (col + row) % 2 == 0 else bg_color
				draw_rect(Rect2(x, y, cs, cs), alt)

	for g: Variant in _grass_details:
		var gv: Vector3 = g as Vector3
		var gc: Color = Color(0.35, 0.65, 0.25, 0.6)
		draw_line(Vector2(gv.x, gv.y), Vector2(gv.x - 1.0, gv.y - gv.z), gc, 1.0)
		draw_line(Vector2(gv.x, gv.y), Vector2(gv.x + 1.5, gv.y - gv.z * 0.8), gc, 1.0)

	for f: Variant in _flower_positions:
		var fv: Vector3 = f as Vector3
		_draw_flower(Vector2(fv.x, fv.y), int(fv.z))

	if _hover_cell.x >= 0:
		var hx: float = float(_hover_cell.x * TDData.CELL_SIZE)
		var hy: float = float(_hover_cell.y * TDData.CELL_SIZE)
		var cs: float = float(TDData.CELL_SIZE)
		var hc: Color = Color(0.2, 1.0, 0.2, 0.3) if _hover_valid else Color(1.0, 0.2, 0.2, 0.3)
		draw_rect(Rect2(hx, hy, cs, cs), hc)

	if _selected_cell.x >= 0:
		var sx: float = float(_selected_cell.x * TDData.CELL_SIZE)
		var sy: float = float(_selected_cell.y * TDData.CELL_SIZE)
		var cs: float = float(TDData.CELL_SIZE)
		draw_rect(Rect2(sx, sy, cs, cs), Color(1.0, 1.0, 0.3, 0.25))
		draw_rect(Rect2(sx + 1.0, sy + 1.0, cs - 2.0, cs - 2.0), Color(1.0, 1.0, 0.3, 0.5), false, 2.0)

		if _range_radius > 0.0:
			var center: Vector2 = TDData.cell_center(_selected_cell.x, _selected_cell.y)
			draw_arc(center, _range_radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.25), 1.5)
			draw_circle(center, _range_radius, Color(1.0, 1.0, 1.0, 0.05))


func _draw_path_cell(x: float, y: float, cs: float, col: int, row: int) -> void:
	var path_c: Color = Color(0.82, 0.72, 0.55)
	draw_rect(Rect2(x, y, cs, cs), path_c)

	var border_c: Color = Color(0.7, 0.6, 0.42)
	var has_top: bool = TDData.is_path(col, row - 1)
	var has_bottom: bool = TDData.is_path(col, row + 1)
	var has_left: bool = TDData.is_path(col - 1, row)
	var has_right: bool = TDData.is_path(col + 1, row)

	if not has_top:
		draw_line(Vector2(x, y), Vector2(x + cs, y), border_c, 2.0)
	if not has_bottom:
		draw_line(Vector2(x, y + cs), Vector2(x + cs, y + cs), border_c, 2.0)
	if not has_left:
		draw_line(Vector2(x, y), Vector2(x, y + cs), border_c, 2.0)
	if not has_right:
		draw_line(Vector2(x + cs, y), Vector2(x + cs, y + cs), border_c, 2.0)

	var dot_c: Color = Color(0.75, 0.65, 0.48, 0.4)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = col * 100 + row
	for _i: int in range(3):
		var dx: float = x + rng.randf_range(6.0, cs - 6.0)
		var dy: float = y + rng.randf_range(6.0, cs - 6.0)
		draw_circle(Vector2(dx, dy), rng.randf_range(1.0, 2.5), dot_c)


func _draw_flower(pos: Vector2, ftype: int) -> void:
	var colors: Array = [
		Color(1.0, 0.65, 0.75),
		Color(0.75, 0.65, 1.0),
		Color(1.0, 0.85, 0.45),
	]
	var c: Color = colors[ftype] as Color
	var petal_r: float = 3.5
	for i: int in range(5):
		var a: float = float(i) / 5.0 * TAU
		draw_circle(pos + Vector2(cos(a) * petal_r, sin(a) * petal_r), 2.5, c)
	draw_circle(pos, 2.0, Color(1.0, 0.9, 0.3))
