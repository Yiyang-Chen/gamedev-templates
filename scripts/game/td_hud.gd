class_name TDHUD extends Control
## Full game UI - top bar, tower panel, upgrade panel, game over overlay


signal tower_button_pressed(type: int)
signal upgrade_pressed()
signal sell_pressed()
signal start_wave_pressed()
signal restart_pressed()


var _money_label: Label = null
var _lives_label: Label = null
var _wave_label: Label = null
var _wave_btn: Button = null
var _tower_panel: HBoxContainer = null
var _info_panel: PanelContainer = null
var _info_name: Label = null
var _info_stats: Label = null
var _upgrade_btn: Button = null
var _sell_btn: Button = null
var _game_over_panel: PanelContainer = null
var _game_over_label: Label = null
var _restart_btn: Button = null
var _speed_btn: Button = null
var _game_speed: float = 1.0
var _tower_buttons: Array = []


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0

	_build_top_bar()
	_build_tower_panel()
	_build_info_panel()
	_build_game_over_panel()


func _build_top_bar() -> void:
	var bar: PanelContainer = PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bar)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_bottom = 56.0

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.22, 0.28, 0.92)
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	bar.add_theme_stylebox_override("panel", sb)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_child(hbox)

	_money_label = _make_label("Coins: 0", 20, Color(1.0, 0.85, 0.2))
	hbox.add_child(_money_label)

	_lives_label = _make_label("Lives: 0", 20, Color(1.0, 0.4, 0.4))
	hbox.add_child(_lives_label)

	_wave_label = _make_label("Wave: 0/0", 20, Color(0.6, 0.85, 1.0))
	hbox.add_child(_wave_label)

	_wave_btn = Button.new()
	_wave_btn.text = "Start Wave"
	_wave_btn.custom_minimum_size = Vector2(130.0, 36.0)
	var wb_sb: StyleBoxFlat = StyleBoxFlat.new()
	wb_sb.bg_color = Color(0.2, 0.7, 0.3)
	wb_sb.corner_radius_top_left = 8
	wb_sb.corner_radius_top_right = 8
	wb_sb.corner_radius_bottom_left = 8
	wb_sb.corner_radius_bottom_right = 8
	wb_sb.content_margin_left = 12.0
	wb_sb.content_margin_right = 12.0
	wb_sb.content_margin_top = 4.0
	wb_sb.content_margin_bottom = 4.0
	_wave_btn.add_theme_stylebox_override("normal", wb_sb)
	var wb_hover: StyleBoxFlat = wb_sb.duplicate() as StyleBoxFlat
	wb_hover.bg_color = Color(0.25, 0.8, 0.35)
	_wave_btn.add_theme_stylebox_override("hover", wb_hover)
	_wave_btn.add_theme_font_size_override("font_size", 16)
	_wave_btn.add_theme_color_override("font_color", Color.WHITE)
	_wave_btn.pressed.connect(func() -> void: start_wave_pressed.emit())
	hbox.add_child(_wave_btn)

	_speed_btn = Button.new()
	_speed_btn.text = "x1"
	_speed_btn.custom_minimum_size = Vector2(50.0, 36.0)
	var sp_sb: StyleBoxFlat = StyleBoxFlat.new()
	sp_sb.bg_color = Color(0.35, 0.35, 0.5)
	sp_sb.corner_radius_top_left = 8
	sp_sb.corner_radius_top_right = 8
	sp_sb.corner_radius_bottom_left = 8
	sp_sb.corner_radius_bottom_right = 8
	sp_sb.content_margin_left = 8.0
	sp_sb.content_margin_right = 8.0
	sp_sb.content_margin_top = 4.0
	sp_sb.content_margin_bottom = 4.0
	_speed_btn.add_theme_stylebox_override("normal", sp_sb)
	var sp_hover: StyleBoxFlat = sp_sb.duplicate() as StyleBoxFlat
	sp_hover.bg_color = Color(0.45, 0.45, 0.6)
	_speed_btn.add_theme_stylebox_override("hover", sp_hover)
	_speed_btn.add_theme_font_size_override("font_size", 14)
	_speed_btn.add_theme_color_override("font_color", Color.WHITE)
	_speed_btn.pressed.connect(_toggle_speed)
	hbox.add_child(_speed_btn)


func _build_tower_panel() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -100.0

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.18, 0.22, 0.28, 0.92)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", sb)

	_tower_panel = HBoxContainer.new()
	_tower_panel.add_theme_constant_override("separation", 8)
	_tower_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(_tower_panel)

	for i: int in range(TDData.TOWER_COUNT):
		var btn: Button = _make_tower_button(i)
		_tower_panel.add_child(btn)
		_tower_buttons.push_back(btn)


func _make_tower_button(idx: int) -> Button:
	var btn: Button = Button.new()
	var tname: String = TDData.TOWER_NAMES[idx] as String
	var cost: int = TDData.TOWER_COSTS[idx] as int
	btn.text = "%s\n$%d" % [tname, cost]
	btn.custom_minimum_size = Vector2(120.0, 72.0)

	var body_c: Color = TDData.TOWER_BODY_COLORS[idx] as Color
	var sb_n: StyleBoxFlat = StyleBoxFlat.new()
	sb_n.bg_color = body_c.darkened(0.4)
	sb_n.corner_radius_top_left = 10
	sb_n.corner_radius_top_right = 10
	sb_n.corner_radius_bottom_left = 10
	sb_n.corner_radius_bottom_right = 10
	sb_n.content_margin_left = 8.0
	sb_n.content_margin_right = 8.0
	sb_n.content_margin_top = 6.0
	sb_n.content_margin_bottom = 6.0
	sb_n.border_width_bottom = 3
	sb_n.border_color = body_c.darkened(0.6)
	btn.add_theme_stylebox_override("normal", sb_n)

	var sb_h: StyleBoxFlat = sb_n.duplicate() as StyleBoxFlat
	sb_h.bg_color = body_c.darkened(0.2)
	btn.add_theme_stylebox_override("hover", sb_h)

	var sb_p: StyleBoxFlat = sb_n.duplicate() as StyleBoxFlat
	sb_p.bg_color = body_c.darkened(0.5)
	btn.add_theme_stylebox_override("pressed", sb_p)

	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)

	var type_copy: int = idx
	btn.pressed.connect(func() -> void: tower_button_pressed.emit(type_copy))
	return btn


func _build_info_panel() -> void:
	_info_panel = PanelContainer.new()
	_info_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_info_panel)
	_info_panel.visible = false
	_info_panel.position = Vector2(920.0, 200.0)
	_info_panel.custom_minimum_size = Vector2(240.0, 180.0)

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.18, 0.25, 0.95)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 12.0
	sb.content_margin_bottom = 12.0
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.4, 0.5, 0.6, 0.5)
	_info_panel.add_theme_stylebox_override("panel", sb)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_info_panel.add_child(vbox)

	_info_name = _make_label("Tower", 18, Color(1.0, 0.9, 0.6))
	vbox.add_child(_info_name)

	_info_stats = _make_label("Stats", 13, Color(0.8, 0.85, 0.9))
	vbox.add_child(_info_stats)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	_upgrade_btn = Button.new()
	_upgrade_btn.text = "Upgrade"
	_upgrade_btn.custom_minimum_size = Vector2(100.0, 34.0)
	var ub_sb: StyleBoxFlat = StyleBoxFlat.new()
	ub_sb.bg_color = Color(0.2, 0.55, 0.8)
	ub_sb.corner_radius_top_left = 6
	ub_sb.corner_radius_top_right = 6
	ub_sb.corner_radius_bottom_left = 6
	ub_sb.corner_radius_bottom_right = 6
	ub_sb.content_margin_left = 8.0
	ub_sb.content_margin_right = 8.0
	ub_sb.content_margin_top = 4.0
	ub_sb.content_margin_bottom = 4.0
	_upgrade_btn.add_theme_stylebox_override("normal", ub_sb)
	var ub_hover: StyleBoxFlat = ub_sb.duplicate() as StyleBoxFlat
	ub_hover.bg_color = Color(0.3, 0.65, 0.9)
	_upgrade_btn.add_theme_stylebox_override("hover", ub_hover)
	_upgrade_btn.add_theme_font_size_override("font_size", 13)
	_upgrade_btn.add_theme_color_override("font_color", Color.WHITE)
	_upgrade_btn.pressed.connect(func() -> void: upgrade_pressed.emit())
	btn_row.add_child(_upgrade_btn)

	_sell_btn = Button.new()
	_sell_btn.text = "Sell"
	_sell_btn.custom_minimum_size = Vector2(100.0, 34.0)
	var sell_sb: StyleBoxFlat = StyleBoxFlat.new()
	sell_sb.bg_color = Color(0.8, 0.25, 0.25)
	sell_sb.corner_radius_top_left = 6
	sell_sb.corner_radius_top_right = 6
	sell_sb.corner_radius_bottom_left = 6
	sell_sb.corner_radius_bottom_right = 6
	sell_sb.content_margin_left = 8.0
	sell_sb.content_margin_right = 8.0
	sell_sb.content_margin_top = 4.0
	sell_sb.content_margin_bottom = 4.0
	_sell_btn.add_theme_stylebox_override("normal", sell_sb)
	var sell_hover: StyleBoxFlat = sell_sb.duplicate() as StyleBoxFlat
	sell_hover.bg_color = Color(0.9, 0.35, 0.35)
	_sell_btn.add_theme_stylebox_override("hover", sell_hover)
	_sell_btn.add_theme_font_size_override("font_size", 13)
	_sell_btn.add_theme_color_override("font_color", Color.WHITE)
	_sell_btn.pressed.connect(func() -> void: sell_pressed.emit())
	btn_row.add_child(_sell_btn)


func _build_game_over_panel() -> void:
	_game_over_panel = PanelContainer.new()
	_game_over_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_game_over_panel)
	_game_over_panel.visible = false
	_game_over_panel.set_anchors_preset(Control.PRESET_CENTER)
	_game_over_panel.custom_minimum_size = Vector2(400.0, 250.0)
	_game_over_panel.offset_left = -200.0
	_game_over_panel.offset_right = 200.0
	_game_over_panel.offset_top = -125.0
	_game_over_panel.offset_bottom = 125.0

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.15, 0.2, 0.97)
	sb.corner_radius_top_left = 16
	sb.corner_radius_top_right = 16
	sb.corner_radius_bottom_left = 16
	sb.corner_radius_bottom_right = 16
	sb.content_margin_left = 24.0
	sb.content_margin_right = 24.0
	sb.content_margin_top = 24.0
	sb.content_margin_bottom = 24.0
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color(0.5, 0.6, 0.7, 0.6)
	_game_over_panel.add_theme_stylebox_override("panel", sb)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_game_over_panel.add_child(vbox)

	_game_over_label = Label.new()
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.add_theme_font_size_override("font_size", 36)
	_game_over_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	vbox.add_child(_game_over_label)

	_restart_btn = Button.new()
	_restart_btn.text = "Play Again"
	_restart_btn.custom_minimum_size = Vector2(160.0, 48.0)
	var rb_sb: StyleBoxFlat = StyleBoxFlat.new()
	rb_sb.bg_color = Color(0.25, 0.65, 0.35)
	rb_sb.corner_radius_top_left = 10
	rb_sb.corner_radius_top_right = 10
	rb_sb.corner_radius_bottom_left = 10
	rb_sb.corner_radius_bottom_right = 10
	rb_sb.content_margin_left = 16.0
	rb_sb.content_margin_right = 16.0
	rb_sb.content_margin_top = 8.0
	rb_sb.content_margin_bottom = 8.0
	_restart_btn.add_theme_stylebox_override("normal", rb_sb)
	var rb_hover: StyleBoxFlat = rb_sb.duplicate() as StyleBoxFlat
	rb_hover.bg_color = Color(0.35, 0.75, 0.45)
	_restart_btn.add_theme_stylebox_override("hover", rb_hover)
	_restart_btn.add_theme_font_size_override("font_size", 20)
	_restart_btn.add_theme_color_override("font_color", Color.WHITE)
	_restart_btn.pressed.connect(func() -> void: restart_pressed.emit())
	vbox.add_child(_restart_btn)
	_restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func update_money(amount: int) -> void:
	_money_label.text = "Coins: %d" % amount
	for i: int in range(_tower_buttons.size()):
		var btn: Button = _tower_buttons[i] as Button
		var cost: int = TDData.TOWER_COSTS[i] as int
		btn.disabled = amount < cost


func update_lives(amount: int) -> void:
	_lives_label.text = "Lives: %d" % amount


func update_wave(wave: int, total: int) -> void:
	_wave_label.text = "Wave: %d/%d" % [wave, total]
	_wave_btn.visible = wave < total


func set_wave_btn_enabled(enabled: bool) -> void:
	_wave_btn.disabled = not enabled


func show_tower_info(tower: TDTower) -> void:
	_info_panel.visible = true
	var tname: String = TDData.TOWER_NAMES[tower.tower_type] as String
	_info_name.text = "%s Lv.%d" % [tname, tower.level + 1]

	var dmg: float = tower.get_damage()
	var rng: float = tower.get_range()
	var spd: float = tower.get_atk_speed()
	var atk_names: Array = ["Single", "Splash", "Slow", "Sniper"]
	var atk_type: int = TDData.TOWER_ATK_TYPES[tower.tower_type] as int
	var atk_name: String = atk_names[atk_type] as String

	_info_stats.text = "DMG: %.0f  RNG: %.0f\nSPD: %.1f  Type: %s\nSell: $%d" % [
		dmg, rng, spd, atk_name, tower.get_sell_price()]

	if tower.can_upgrade():
		_upgrade_btn.visible = true
		_upgrade_btn.text = "Upgrade $%d" % tower.get_upgrade_cost()
	else:
		_upgrade_btn.visible = false

	var tw_pos: Vector2 = TDData.cell_center(tower.grid_col, tower.grid_row)
	var px: float = tw_pos.x + 60.0
	if px + 250.0 > 1280.0:
		px = tw_pos.x - 300.0
	var py: float = tw_pos.y - 90.0
	py = clampf(py, 60.0, 500.0)
	_info_panel.position = Vector2(px, py)


func hide_tower_info() -> void:
	_info_panel.visible = false


func show_game_over(won: bool) -> void:
	_game_over_panel.visible = true
	if won:
		_game_over_label.text = "Victory!\nAll pests defeated!"
		_game_over_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		_game_over_label.text = "Game Over!\nThe pests got through!"
		_game_over_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))


func _toggle_speed() -> void:
	if _game_speed < 1.5:
		_game_speed = 2.0
		_speed_btn.text = "x2"
	elif _game_speed < 2.5:
		_game_speed = 3.0
		_speed_btn.text = "x3"
	else:
		_game_speed = 1.0
		_speed_btn.text = "x1"
	Engine.time_scale = _game_speed


func _make_label(txt: String, size: int, color: Color) -> Label:
	var lbl: Label = Label.new()
	lbl.text = txt
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl
