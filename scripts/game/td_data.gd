class_name TDData extends RefCounted
## Static game data for Fruit Defense tower defense game


const CELL_SIZE: int = 64
const GRID_COLS: int = 20
const GRID_ROWS: int = 10
const HUD_HEIGHT: float = 80.0
const TOWER_COUNT: int = 5
const MAX_UPGRADE: int = 3
const START_MONEY: int = 250
const START_LIVES: int = 20
const SELL_RATE: float = 0.6
const TOTAL_WAVES: int = 10

const ATK_SINGLE: int = 0
const ATK_SPLASH: int = 1
const ATK_SLOW: int = 2
const ATK_SNIPER: int = 3

const TOWER_NAMES: Array = ["Strawberry", "Watermelon", "Lemon", "Pineapple", "Cherry"]
const TOWER_COSTS: Array = [80, 120, 100, 150, 200]
const TOWER_RANGES: Array = [150.0, 130.0, 140.0, 200.0, 120.0]
const TOWER_DAMAGES: Array = [8.0, 15.0, 5.0, 25.0, 35.0]
const TOWER_ATK_SPEEDS: Array = [2.0, 0.8, 1.5, 0.5, 0.4]
const TOWER_PROJ_SPEEDS: Array = [400.0, 300.0, 350.0, 500.0, 250.0]
const TOWER_ATK_TYPES: Array = [ATK_SINGLE, ATK_SPLASH, ATK_SLOW, ATK_SNIPER, ATK_SPLASH]
const TOWER_SPLASH_R: Array = [0.0, 60.0, 0.0, 0.0, 80.0]
const TOWER_SLOW_F: Array = [0.0, 0.0, 0.5, 0.0, 0.0]

const UPGRADE_COSTS: Array = [
	[60, 120, 200],
	[100, 180, 300],
	[80, 150, 250],
	[120, 200, 350],
	[160, 280, 400],
]

const UPG_DMG: Array = [1.5, 2.2, 3.2]
const UPG_RNG: Array = [1.1, 1.2, 1.35]
const UPG_SPD: Array = [1.15, 1.3, 1.5]

const TOWER_BODY_COLORS: Array = [
	Color(0.92, 0.22, 0.22),
	Color(0.25, 0.72, 0.35),
	Color(1.0, 0.92, 0.25),
	Color(0.88, 0.62, 0.12),
	Color(0.82, 0.12, 0.18),
]
const TOWER_HIGHLIGHT_COLORS: Array = [
	Color(1.0, 0.55, 0.55),
	Color(0.55, 0.92, 0.55),
	Color(1.0, 1.0, 0.65),
	Color(1.0, 0.82, 0.42),
	Color(1.0, 0.45, 0.45),
]
const TOWER_ACCENT_COLORS: Array = [
	Color(0.3, 0.72, 0.22),
	Color(0.92, 0.35, 0.42),
	Color(0.35, 0.72, 0.22),
	Color(0.22, 0.65, 0.15),
	Color(0.22, 0.55, 0.15),
]

const ENEMY_NAMES: Array = ["Caterpillar", "Aphid", "Beetle", "Fly", "Slug"]
const ENEMY_SPEEDS: Array = [55.0, 95.0, 38.0, 75.0, 28.0]
const ENEMY_HPS: Array = [30.0, 15.0, 80.0, 40.0, 200.0]
const ENEMY_REWARDS: Array = [10, 8, 20, 15, 50]
const ENEMY_SIZES: Array = [11.0, 8.0, 13.0, 10.0, 17.0]

const ENEMY_BODY_COLORS: Array = [
	Color(0.42, 0.82, 0.22),
	Color(0.72, 0.92, 0.32),
	Color(0.42, 0.28, 0.12),
	Color(0.52, 0.52, 0.58),
	Color(0.62, 0.32, 0.72),
]
const ENEMY_HIGHLIGHT_COLORS: Array = [
	Color(0.62, 0.92, 0.42),
	Color(0.92, 1.0, 0.62),
	Color(0.62, 0.42, 0.22),
	Color(0.72, 0.72, 0.78),
	Color(0.82, 0.52, 0.92),
]

const MAP: Array = [
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
	[0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
	[1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

const PATH_WAYPOINTS: Array = [
	Vector2(-32.0, 288.0),
	Vector2(288.0, 288.0),
	Vector2(288.0, 96.0),
	Vector2(608.0, 96.0),
	Vector2(608.0, 480.0),
	Vector2(928.0, 480.0),
	Vector2(928.0, 160.0),
	Vector2(1312.0, 160.0),
]

const WAVES: Array = [
	[[0, 5, 1.5]],
	[[0, 6, 1.2], [1, 3, 1.0]],
	[[1, 10, 0.8]],
	[[0, 5, 1.0], [2, 3, 2.0]],
	[[1, 6, 0.8], [2, 4, 1.5], [0, 4, 1.0]],
	[[3, 8, 1.0], [0, 5, 1.2]],
	[[2, 8, 1.2], [3, 4, 1.0]],
	[[1, 10, 0.6], [2, 5, 1.5], [3, 5, 1.0]],
	[[4, 2, 3.0], [2, 6, 1.2]],
	[[4, 3, 2.5], [3, 8, 0.8], [2, 5, 1.0]],
]


static func cell_center(col: int, row: int) -> Vector2:
	return Vector2(float(col) * float(CELL_SIZE) + float(CELL_SIZE) * 0.5,
		float(row) * float(CELL_SIZE) + float(CELL_SIZE) * 0.5)


static func pixel_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x) / CELL_SIZE, int(pos.y) / CELL_SIZE)


static func is_buildable(col: int, row: int) -> bool:
	if col < 0 or col >= GRID_COLS or row < 0 or row >= GRID_ROWS:
		return false
	var r: Array = MAP[row] as Array
	return (r[col] as int) == 0


static func is_path(col: int, row: int) -> bool:
	if col < 0 or col >= GRID_COLS or row < 0 or row >= GRID_ROWS:
		return false
	var r: Array = MAP[row] as Array
	return (r[col] as int) == 1


static func get_tower_damage(t: int, lvl: int) -> float:
	var base: float = TOWER_DAMAGES[t] as float
	if lvl > 0 and lvl <= MAX_UPGRADE:
		return base * (UPG_DMG[lvl - 1] as float)
	return base


static func get_tower_range(t: int, lvl: int) -> float:
	var base: float = TOWER_RANGES[t] as float
	if lvl > 0 and lvl <= MAX_UPGRADE:
		return base * (UPG_RNG[lvl - 1] as float)
	return base


static func get_tower_atk_speed(t: int, lvl: int) -> float:
	var base: float = TOWER_ATK_SPEEDS[t] as float
	if lvl > 0 and lvl <= MAX_UPGRADE:
		return base * (UPG_SPD[lvl - 1] as float)
	return base


static func get_upgrade_cost(t: int, target_lvl: int) -> int:
	if target_lvl < 1 or target_lvl > MAX_UPGRADE:
		return -1
	var costs: Array = UPGRADE_COSTS[t] as Array
	return costs[target_lvl - 1] as int


static func get_total_investment(t: int, lvl: int) -> int:
	var total: int = TOWER_COSTS[t] as int
	for i: int in range(1, lvl + 1):
		var c: Array = UPGRADE_COSTS[t] as Array
		total += c[i - 1] as int
	return total


static func get_sell_price(t: int, lvl: int) -> int:
	return int(float(get_total_investment(t, lvl)) * SELL_RATE)
