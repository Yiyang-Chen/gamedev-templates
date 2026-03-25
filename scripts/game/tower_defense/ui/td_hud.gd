class_name TDHUD extends Control

## Top HUD bar showing gold, lives, wave info, and speed controls.

var _gold: int = 0
var _lives: int = 0
var _wave: int = 0
var _total_waves: int = 0
var _game_speed: float = 1.0

signal speed_changed(new_speed: float)
signal next_wave_requested()

var _next_wave_btn_rect: Rect2 = Rect2()
var _speed_btn_rect: Rect2 = Rect2()
var _wave_active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func update_display(gold: int, lives: int, wave: int, total_waves: int, wave_active: bool) -> void:
	_gold = gold
	_lives = lives
	_wave = wave
	_total_waves = total_waves
	_wave_active = wave_active
	queue_redraw()

func set_game_speed(spd: float) -> void:
	_game_speed = spd
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _next_wave_btn_rect.has_point(mb.position) and not _wave_active:
				next_wave_requested.emit()
			elif _speed_btn_rect.has_point(mb.position):
				if _game_speed < 1.5:
					_game_speed = 2.0
				elif _game_speed < 2.5:
					_game_speed = 3.0
				else:
					_game_speed = 1.0
				speed_changed.emit(_game_speed)
				queue_redraw()

func _draw() -> void:
	# Top bar background
	var bar_h: float = 40.0
	draw_rect(Rect2(0, 0, size.x, bar_h), Color(0.1, 0.12, 0.18, 0.9))
	draw_rect(Rect2(0, bar_h - 2, size.x, 2), Color(0.3, 0.5, 0.3, 0.6))

	var font: Font = ThemeDB.fallback_font

	# Gold
	draw_circle(Vector2(25, 20), 8, Color(1.0, 0.85, 0.1))
	draw_circle(Vector2(24, 19), 3, Color(1.0, 0.95, 0.5))
	draw_string(font, Vector2(38, 26), str(_gold), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.9, 0.3))

	# Lives
	draw_circle(Vector2(150, 20), 8, Color(0.9, 0.2, 0.3))
	draw_circle(Vector2(149, 18), 3, Color(1.0, 0.5, 0.5))
	draw_string(font, Vector2(163, 26), str(_lives), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.95, 0.4, 0.4))

	# Wave info
	var wave_text: String = "波次: %d/%d" % [_wave, _total_waves]
	draw_string(font, Vector2(250, 26), wave_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.85, 0.85, 0.9))

	# Next wave button
	var btn_w: float = 80.0
	var btn_h: float = 28.0
	var btn_x: float = 420.0
	var btn_y: float = 6.0
	_next_wave_btn_rect = Rect2(btn_x, btn_y, btn_w, btn_h)
	var btn_color: Color = Color(0.2, 0.6, 0.3, 0.9) if not _wave_active else Color(0.3, 0.3, 0.3, 0.5)
	draw_rect(_next_wave_btn_rect, btn_color)
	draw_rect(_next_wave_btn_rect, Color(1, 1, 1, 0.2), false, 1.0)
	var btn_text: String = "下一波" if not _wave_active else "进行中..."
	draw_string(font, Vector2(btn_x + 12.0, btn_y + 20.0), btn_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

	# Speed button
	var spd_x: float = 520.0
	_speed_btn_rect = Rect2(spd_x, btn_y, 50, btn_h)
	draw_rect(_speed_btn_rect, Color(0.3, 0.3, 0.5, 0.8))
	draw_rect(_speed_btn_rect, Color(1, 1, 1, 0.2), false, 1.0)
	var spd_text: String = "x%d" % int(_game_speed)
	draw_string(font, Vector2(spd_x + 14.0, btn_y + 20.0), spd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.8, 1.0))
