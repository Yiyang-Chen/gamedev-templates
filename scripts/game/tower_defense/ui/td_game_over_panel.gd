class_name TDGameOverPanel extends Control

## Panel shown when the game ends (win or lose).

var _is_victory: bool = false
var _wave_reached: int = 0
var _retry_btn_rect: Rect2 = Rect2()

signal retry_requested()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func show_result(victory: bool, wave: int) -> void:
	_is_victory = victory
	_wave_reached = wave
	visible = true
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _retry_btn_rect.has_point(mb.position):
				retry_requested.emit()

func _draw() -> void:
	if not visible:
		return

	# Full screen overlay
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))

	var font: Font = ThemeDB.fallback_font
	var cx: float = size.x / 2.0
	var cy: float = size.y / 2.0

	# Result panel
	var panel_w: float = 320.0
	var panel_h: float = 200.0
	var panel_rect: Rect2 = Rect2(cx - panel_w / 2.0, cy - panel_h / 2.0, panel_w, panel_h)
	draw_rect(panel_rect, Color(0.12, 0.15, 0.22, 0.95))
	draw_rect(panel_rect, Color(0.5, 0.7, 0.5, 0.4), false, 2.0)

	# Title
	var title: String = "胜利！" if _is_victory else "失败！"
	var title_color: Color = Color(0.2, 1.0, 0.3) if _is_victory else Color(1.0, 0.3, 0.3)
	draw_string(font, Vector2(cx - 30, cy - 50), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 28, title_color)

	# Wave info
	var wave_text: String = "到达波次: %d" % _wave_reached
	draw_string(font, Vector2(cx - 40, cy - 10), wave_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.85, 0.85, 0.9))

	# Subtitle
	var sub: String = "所有害虫被击退了！" if _is_victory else "水果基地被害虫攻陷了..."
	draw_string(font, Vector2(cx - 80, cy + 20), sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.7, 0.7, 0.75))

	# Retry button
	var btn_w: float = 120.0
	var btn_h: float = 36.0
	_retry_btn_rect = Rect2(cx - btn_w / 2.0, cy + 45, btn_w, btn_h)
	draw_rect(_retry_btn_rect, Color(0.2, 0.5, 0.3, 0.9))
	draw_rect(_retry_btn_rect, Color(1, 1, 1, 0.3), false, 1.5)
	draw_string(font, Vector2(cx - 25, cy + 70), "再来一局", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color.WHITE)
