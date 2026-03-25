class_name TDStartScreen extends Control

## Title screen shown at the start of the game.

var _start_btn_rect: Rect2 = Rect2()
var _anim_time: float = 0.0

signal start_game_requested()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = Vector2(1280, 720)

func _process(delta: float) -> void:
	_anim_time += delta
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _start_btn_rect.has_point(mb.position):
				start_game_requested.emit()

func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var cx: float = size.x / 2.0
	var cy: float = size.y / 2.0

	# Background gradient
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.18, 0.35, 0.18))

	# Grass texture at bottom
	for i: int in range(40):
		var gx: float = float(i) * 32.0 + sin(_anim_time * 0.5 + float(i) * 0.3) * 3.0
		var gy: float = size.y - 60.0 + sin(float(i) * 0.7) * 20.0
		draw_circle(Vector2(gx, gy), 18.0, Color(0.25, 0.55, 0.2, 0.6))
		draw_circle(Vector2(gx + 8, gy + 8), 14.0, Color(0.3, 0.6, 0.25, 0.5))

	# Decorative fruits floating
	_draw_floating_fruit(cx - 280, cy - 100, 0.0, Color(0.2, 0.7, 0.3), 25.0)
	_draw_floating_fruit(cx + 260, cy - 80, 1.0, Color(0.9, 0.2, 0.3), 22.0)
	_draw_floating_fruit(cx - 200, cy + 50, 2.0, Color(1.0, 0.6, 0.1), 20.0)
	_draw_floating_fruit(cx + 180, cy + 60, 3.0, Color(0.5, 0.2, 0.7), 18.0)
	_draw_floating_fruit(cx, cy + 100, 4.0, Color(0.9, 0.8, 0.1), 22.0)

	# Decorative bugs
	_draw_floating_bug(cx - 350, cy + 30, 0.5)
	_draw_floating_bug(cx + 320, cy + 40, 1.5)
	_draw_floating_bug(cx - 100, cy + 140, 2.5)
	_draw_floating_bug(cx + 150, cy + 130, 3.5)

	# Title shadow
	draw_string(font, Vector2(cx - 158, cy - 128), "水果大战害虫", HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color(0, 0, 0, 0.3))
	# Title
	var title_color: Color = Color(1.0, 0.9, 0.3).lerp(Color(0.3, 1.0, 0.4), sin(_anim_time * 1.5) * 0.5 + 0.5)
	draw_string(font, Vector2(cx - 160, cy - 130), "水果大战害虫", HORIZONTAL_ALIGNMENT_CENTER, -1, 42, title_color)

	# Subtitle
	draw_string(font, Vector2(cx - 95, cy - 85), "- 塔防保卫战 -", HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color(0.8, 0.85, 0.7, 0.8))

	# Description
	draw_string(font, Vector2(cx - 130, cy - 45), "放置各种水果保卫基地", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(0.75, 0.8, 0.7))
	draw_string(font, Vector2(cx - 110, cy - 25), "消灭来犯的害虫！", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(0.75, 0.8, 0.7))

	# Start button
	var btn_w: float = 180.0
	var btn_h: float = 50.0
	var bounce: float = sin(_anim_time * 2.0) * 3.0
	_start_btn_rect = Rect2(cx - btn_w / 2.0, cy + 10 + bounce, btn_w, btn_h)

	# Button glow
	draw_rect(Rect2(_start_btn_rect.position.x - 2, _start_btn_rect.position.y - 2, _start_btn_rect.size.x + 4, _start_btn_rect.size.y + 4), Color(0.3, 0.8, 0.3, 0.3 + sin(_anim_time * 3.0) * 0.15))
	draw_rect(_start_btn_rect, Color(0.2, 0.6, 0.25, 0.95))
	draw_rect(_start_btn_rect, Color(0.4, 0.9, 0.4, 0.5), false, 2.0)
	draw_string(font, Vector2(cx - 40, cy + 42 + bounce), "开始游戏", HORIZONTAL_ALIGNMENT_CENTER, -1, 22, Color.WHITE)

	# Instructions
	var inst_y: float = cy + 90
	draw_string(font, Vector2(cx - 160, inst_y), "左键选择水果并放置 | 右键取消", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.6, 0.65, 0.55, 0.7))
	draw_string(font, Vector2(cx - 140, inst_y + 18), "点击已放置的水果进行升级", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.6, 0.65, 0.55, 0.7))

func _draw_floating_fruit(fx: float, fy: float, phase: float, col: Color, rad: float) -> void:
	var bounce: float = sin(_anim_time * 1.2 + phase) * 8.0
	var pos: Vector2 = Vector2(fx, fy + bounce)
	# Shadow
	draw_circle(Vector2(fx + 2, fy + rad + 5), rad * 0.5, Color(0, 0, 0, 0.1))
	# Body
	draw_circle(pos, rad, col)
	draw_circle(pos + Vector2(-rad * 0.25, -rad * 0.25), rad * 0.35, col.lightened(0.3))
	# Eyes
	draw_circle(pos + Vector2(-rad * 0.2, -rad * 0.1), 2.5, Color.WHITE)
	draw_circle(pos + Vector2(rad * 0.2, -rad * 0.1), 2.5, Color.WHITE)
	draw_circle(pos + Vector2(-rad * 0.15, -rad * 0.05), 1.2, Color(0.15, 0.1, 0.1))
	draw_circle(pos + Vector2(rad * 0.25, -rad * 0.05), 1.2, Color(0.15, 0.1, 0.1))
	# Smile
	draw_arc(pos + Vector2(0, rad * 0.15), rad * 0.2, 0.2, PI - 0.2, 6, Color(0.15, 0.1, 0.1), 1.5)

func _draw_floating_bug(bx: float, by: float, phase: float) -> void:
	var wiggle: float = sin(_anim_time * 2.0 + phase) * 5.0
	var pos: Vector2 = Vector2(bx + wiggle, by)
	draw_circle(pos, 8.0, Color(0.3, 0.2, 0.1, 0.5))
	draw_circle(pos + Vector2(-5, 0), 5.0, Color(0.25, 0.15, 0.08, 0.5))
	# Legs
	for i: int in range(3):
		var lx: float = -3.0 + float(i) * 4.0
		draw_line(pos + Vector2(lx, 5), pos + Vector2(lx - 2, 10), Color(0.2, 0.1, 0.05, 0.4), 1.0)
		draw_line(pos + Vector2(lx, -5), pos + Vector2(lx - 2, -10), Color(0.2, 0.1, 0.05, 0.4), 1.0)
