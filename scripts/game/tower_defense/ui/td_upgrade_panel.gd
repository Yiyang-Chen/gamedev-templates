class_name TDUpgradePanel extends Control

## Panel shown when clicking an existing tower, allowing upgrade or sell.

var _tower: TDTower = null
var _gold: int = 0
var _upgrade_btn_rect: Rect2 = Rect2()
var _sell_btn_rect: Rect2 = Rect2()
var _close_btn_rect: Rect2 = Rect2()

signal upgrade_requested(tower: TDTower)
signal sell_requested(tower: TDTower)
signal panel_closed()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func show_for_tower(tower: TDTower, gold: int) -> void:
	_tower = tower
	_gold = gold
	visible = true
	tower.show_range(true)

	var tower_screen_pos: Vector2 = tower.position
	position = Vector2(
		clampf(tower_screen_pos.x - size.x / 2.0, 0, 1280.0 - size.x),
		clampf(tower_screen_pos.y - size.y - 40.0, 0, 720.0 - size.y)
	)
	queue_redraw()

func hide_panel() -> void:
	if _tower != null:
		_tower.show_range(false)
	_tower = null
	visible = false
	panel_closed.emit()

func update_gold(gold: int) -> void:
	_gold = gold
	if visible:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible or _tower == null:
		return
	if event is InputEventMouseButton:
		@warning_ignore("unsafe_cast")
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _upgrade_btn_rect.has_point(mb.position):
				if _tower.can_upgrade() and _gold >= _tower.get_upgrade_cost():
					upgrade_requested.emit(_tower)
			elif _sell_btn_rect.has_point(mb.position):
				sell_requested.emit(_tower)
			elif _close_btn_rect.has_point(mb.position):
				hide_panel()

func _draw() -> void:
	if _tower == null:
		return

	var font: Font = ThemeDB.fallback_font
	var stats: TDGameData.TowerStats = _tower.get_stats()

	# Background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.1, 0.12, 0.18, 0.92))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.5, 0.7, 0.5, 0.3), false, 2.0)

	# Tower name and level
	var name: String = TDGameData.TOWER_NAMES[_tower.tower_type]
	var level_text: String = " Lv.%d" % (_tower.level + 1)
	draw_string(font, Vector2(8, 18), name + level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.9, 0.5))

	# Stats
	var stats_text: String = "伤害: %.0f  范围: %.0f  攻速: %.1f" % [stats.damage, stats.attack_range, stats.attack_speed]
	draw_string(font, Vector2(8, 36), stats_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.8, 0.85))

	# Upgrade button
	var btn_y: float = 45.0
	_upgrade_btn_rect = Rect2(8, btn_y, 100, 26)
	if _tower.can_upgrade():
		var uc: int = _tower.get_upgrade_cost()
		var can_afford: bool = _gold >= uc
		var btn_color: Color = Color(0.2, 0.5, 0.7, 0.9) if can_afford else Color(0.3, 0.3, 0.3, 0.6)
		draw_rect(_upgrade_btn_rect, btn_color)
		draw_rect(_upgrade_btn_rect, Color(1, 1, 1, 0.2), false, 1.0)
		var upgrade_text: String = "升级 (%d)" % uc
		var txt_color: Color = Color.WHITE if can_afford else Color(0.5, 0.5, 0.5)
		draw_string(font, Vector2(14, btn_y + 18), upgrade_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, txt_color)
	else:
		draw_rect(_upgrade_btn_rect, Color(0.2, 0.2, 0.2, 0.4))
		draw_string(font, Vector2(14, btn_y + 18), "已满级", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.6, 0.6))

	# Sell button
	_sell_btn_rect = Rect2(120, btn_y, 80, 26)
	draw_rect(_sell_btn_rect, Color(0.6, 0.25, 0.2, 0.9))
	draw_rect(_sell_btn_rect, Color(1, 1, 1, 0.2), false, 1.0)
	var sell_text: String = "出售 (%d)" % _tower.get_sell_value()
	draw_string(font, Vector2(126, btn_y + 18), sell_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	# Close button
	_close_btn_rect = Rect2(size.x - 22, 4, 18, 18)
	draw_rect(_close_btn_rect, Color(0.5, 0.2, 0.2, 0.7))
	draw_string(font, Vector2(size.x - 19, 18), "X", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
