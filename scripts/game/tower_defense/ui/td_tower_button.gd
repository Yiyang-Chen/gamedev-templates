class_name TDTowerButton extends Control

## A button in the tower selection panel showing a tower type.

var tower_type: int = TDGameData.TowerType.WATERMELON
var _hovered: bool = false
var _pressed_state: bool = false
var _selected: bool = false
var _affordable: bool = true

signal tower_selected(tt: int)

func setup(tt: int) -> void:
	tower_type = tt
	custom_minimum_size = Vector2(60, 72)
	mouse_filter = Control.MOUSE_FILTER_STOP
	@warning_ignore("unsafe_cast")
	var tower_name: String = TDGameData.TOWER_NAMES[tt] as String
	@warning_ignore("unsafe_cast")
	var tower_desc: String = TDGameData.TOWER_DESCRIPTIONS[tt] as String
	tooltip_text = tower_name + "\n" + tower_desc

func set_affordable(can_afford: bool) -> void:
	_affordable = can_afford
	queue_redraw()

func set_selected(sel: bool) -> void:
	_selected = sel
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed and _affordable:
			tower_selected.emit(tower_type)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_hovered = true
			queue_redraw()
		NOTIFICATION_MOUSE_EXIT:
			_hovered = false
			_pressed_state = false
			queue_redraw()

func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)

	# Background
	var bg_color: Color = Color(0.15, 0.15, 0.2, 0.85)
	if _selected:
		bg_color = Color(0.25, 0.35, 0.5, 0.9)
	elif _hovered and _affordable:
		bg_color = Color(0.2, 0.25, 0.35, 0.9)
	if not _affordable:
		bg_color = Color(0.15, 0.15, 0.15, 0.6)

	draw_rect(rect, bg_color)
	draw_rect(rect, Color(1, 1, 1, 0.3 if _selected else 0.15), false, 1.5)

	# Tower icon
	var center: Vector2 = Vector2(size.x / 2.0, size.y / 2.0 - 8.0)
	var icon_r: float = 14.0
	@warning_ignore("unsafe_cast")
	var tc: Color = TDGameData.TOWER_COLORS[tower_type] as Color
	@warning_ignore("unsafe_cast")
	var ac: Color = TDGameData.TOWER_ACCENT_COLORS[tower_type] as Color
	if not _affordable:
		tc = tc.darkened(0.4)
		ac = ac.darkened(0.4)

	draw_circle(center, icon_r, tc)
	draw_circle(center + Vector2(-3, -3), icon_r * 0.3, tc.lightened(0.3))
	draw_circle(center, icon_r * 0.4, ac)

	# Eyes
	draw_circle(center + Vector2(-3, -2), 2.0, Color.WHITE)
	draw_circle(center + Vector2(3, -2), 2.0, Color.WHITE)
	draw_circle(center + Vector2(-2.5, -1.5), 1.0, Color.BLACK)
	draw_circle(center + Vector2(3.5, -1.5), 1.0, Color.BLACK)

	# Cost text
	var cost: int = TDGameData.get_tower_stats(tower_type, 0).cost
	var cost_color: Color = Color(1.0, 0.85, 0.1) if _affordable else Color(0.6, 0.4, 0.4)
	draw_string(ThemeDB.fallback_font, Vector2(size.x / 2.0 - 12.0, size.y - 4.0), str(cost), HORIZONTAL_ALIGNMENT_CENTER, -1, 11, cost_color)
