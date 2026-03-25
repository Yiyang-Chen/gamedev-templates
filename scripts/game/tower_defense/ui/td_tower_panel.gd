class_name TDTowerPanel extends Control

## Right-side panel for selecting towers to build.

var _buttons: Array[TDTowerButton] = []
var _selected_type: int = -1
var _gold: int = 0

signal tower_type_selected(tt: int)
signal tower_type_deselected()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup() -> void:
	var types: Array[int] = [
		TDGameData.TowerType.WATERMELON,
		TDGameData.TowerType.STRAWBERRY,
		TDGameData.TowerType.ORANGE,
		TDGameData.TowerType.GRAPE,
		TDGameData.TowerType.PINEAPPLE,
	]

	var y_offset: float = 10.0
	for tt: int in types:
		var btn: TDTowerButton = TDTowerButton.new()
		btn.setup(tt)
		btn.position = Vector2(5, y_offset)
		btn.size = Vector2(60, 72)
		btn.tower_selected.connect(_on_tower_selected)
		add_child(btn)
		_buttons.append(btn)
		y_offset += 78.0

func update_gold(gold: int) -> void:
	_gold = gold
	for btn: TDTowerButton in _buttons:
		var cost: int = TDGameData.get_tower_stats(btn.tower_type, 0).cost
		btn.set_affordable(gold >= cost)

func deselect() -> void:
	_selected_type = -1
	for btn: TDTowerButton in _buttons:
		btn.set_selected(false)
	tower_type_deselected.emit()

func get_selected_type() -> int:
	return _selected_type

func _on_tower_selected(tt: int) -> void:
	if _selected_type == tt:
		deselect()
		return
	_selected_type = tt
	for btn: TDTowerButton in _buttons:
		btn.set_selected(btn.tower_type == tt)
	tower_type_selected.emit(tt)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.14, 0.2, 0.85))
	draw_rect(Rect2(0, 0, 2, size.y), Color(0.3, 0.5, 0.3, 0.5))

	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(10, size.y - 8), "水果", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.7, 0.8))
