class_name TDGameData extends RefCounted

## Static game configuration for the tower defense game.
## All balance values, tower/enemy definitions, wave configs live here.

# ========================================
# Map Configuration
# ========================================

const TILE_SIZE: int = 64
const MAP_COLS: int = 20
const MAP_ROWS: int = 11

enum CellType {
	GRASS,
	PATH,
	BUILDABLE,
	BLOCKED,
	START,
	END
}

# ========================================
# Tower Types
# ========================================

enum TowerType {
	WATERMELON,
	STRAWBERRY,
	ORANGE,
	GRAPE,
	PINEAPPLE
}

## Tower display names
static var TOWER_NAMES: Dictionary = {
	TowerType.WATERMELON: "西瓜",
	TowerType.STRAWBERRY: "草莓",
	TowerType.ORANGE: "橙子",
	TowerType.GRAPE: "葡萄",
	TowerType.PINEAPPLE: "菠萝"
}

## Tower descriptions
static var TOWER_DESCRIPTIONS: Dictionary = {
	TowerType.WATERMELON: "发射西瓜子弹，造成范围伤害",
	TowerType.STRAWBERRY: "发射酸甜浆果，减速敌人",
	TowerType.ORANGE: "投掷橙子炸弹，范围爆炸",
	TowerType.GRAPE: "连续发射葡萄弹，攻速快",
	TowerType.PINEAPPLE: "菠萝冲击波，穿透多个敌人"
}

## Tower base colors (body)
static var TOWER_COLORS: Dictionary = {
	TowerType.WATERMELON: Color(0.2, 0.7, 0.3),
	TowerType.STRAWBERRY: Color(0.9, 0.2, 0.3),
	TowerType.ORANGE: Color(1.0, 0.6, 0.1),
	TowerType.GRAPE: Color(0.5, 0.2, 0.7),
	TowerType.PINEAPPLE: Color(0.9, 0.8, 0.1)
}

## Tower accent colors (highlight)
static var TOWER_ACCENT_COLORS: Dictionary = {
	TowerType.WATERMELON: Color(0.85, 0.2, 0.25),
	TowerType.STRAWBERRY: Color(0.3, 0.8, 0.3),
	TowerType.ORANGE: Color(1.0, 0.85, 0.3),
	TowerType.GRAPE: Color(0.7, 0.5, 0.9),
	TowerType.PINEAPPLE: Color(0.5, 0.75, 0.2)
}

## Tower projectile colors
static var TOWER_PROJECTILE_COLORS: Dictionary = {
	TowerType.WATERMELON: Color(0.1, 0.1, 0.1),
	TowerType.STRAWBERRY: Color(0.9, 0.3, 0.4),
	TowerType.ORANGE: Color(1.0, 0.7, 0.2),
	TowerType.GRAPE: Color(0.6, 0.3, 0.8),
	TowerType.PINEAPPLE: Color(0.95, 0.9, 0.3)
}

class TowerStats extends RefCounted:
	var damage: float = 0.0
	var attack_range: float = 0.0
	var attack_speed: float = 0.0
	var cost: int = 0
	var upgrade_cost: int = 0
	var special_value: float = 0.0

	func _init(d: float, r: float, s: float, c: int, uc: int, sv: float = 0.0) -> void:
		damage = d
		attack_range = r
		attack_speed = s
		cost = c
		upgrade_cost = uc
		special_value = sv

## Tower stats per level [level0, level1, level2, level3]
## damage, range, attack_speed(shots/sec), cost, upgrade_cost, special_value
static func get_tower_stats(tower_type: int, level: int) -> TowerStats:
	var _data: Dictionary = {
		TowerType.WATERMELON: [
			TowerStats.new(15.0, 120.0, 0.8, 80, 60, 40.0),
			TowerStats.new(25.0, 140.0, 0.9, 0, 100, 50.0),
			TowerStats.new(40.0, 160.0, 1.0, 0, 160, 65.0),
			TowerStats.new(60.0, 180.0, 1.2, 0, 0, 80.0),
		],
		TowerType.STRAWBERRY: [
			TowerStats.new(8.0, 130.0, 1.2, 60, 50, 0.3),
			TowerStats.new(12.0, 150.0, 1.4, 0, 80, 0.4),
			TowerStats.new(18.0, 170.0, 1.6, 0, 130, 0.5),
			TowerStats.new(28.0, 190.0, 1.8, 0, 0, 0.6),
		],
		TowerType.ORANGE: [
			TowerStats.new(25.0, 110.0, 0.5, 100, 80, 60.0),
			TowerStats.new(40.0, 125.0, 0.6, 0, 120, 70.0),
			TowerStats.new(60.0, 140.0, 0.7, 0, 180, 85.0),
			TowerStats.new(90.0, 160.0, 0.8, 0, 0, 100.0),
		],
		TowerType.GRAPE: [
			TowerStats.new(5.0, 100.0, 3.0, 50, 40, 0.0),
			TowerStats.new(8.0, 110.0, 3.5, 0, 70, 0.0),
			TowerStats.new(12.0, 125.0, 4.0, 0, 110, 0.0),
			TowerStats.new(18.0, 140.0, 5.0, 0, 0, 0.0),
		],
		TowerType.PINEAPPLE: [
			TowerStats.new(12.0, 140.0, 0.7, 90, 70, 3.0),
			TowerStats.new(20.0, 160.0, 0.8, 0, 110, 4.0),
			TowerStats.new(30.0, 180.0, 0.9, 0, 170, 5.0),
			TowerStats.new(45.0, 200.0, 1.0, 0, 0, 6.0),
		],
	}
	var clamped_level: int = clampi(level, 0, 3)
	var stats_array: Array = _data[tower_type]
	return stats_array[clamped_level]

# ========================================
# Enemy Types
# ========================================

enum EnemyType {
	ANT,
	CATERPILLAR,
	BEETLE,
	LOCUST,
	BOSS_SPIDER
}

static var ENEMY_NAMES: Dictionary = {
	EnemyType.ANT: "蚂蚁",
	EnemyType.CATERPILLAR: "毛毛虫",
	EnemyType.BEETLE: "甲虫",
	EnemyType.LOCUST: "蝗虫",
	EnemyType.BOSS_SPIDER: "蜘蛛Boss"
}

static var ENEMY_COLORS: Dictionary = {
	EnemyType.ANT: Color(0.3, 0.2, 0.1),
	EnemyType.CATERPILLAR: Color(0.4, 0.7, 0.2),
	EnemyType.BEETLE: Color(0.15, 0.15, 0.3),
	EnemyType.LOCUST: Color(0.6, 0.65, 0.1),
	EnemyType.BOSS_SPIDER: Color(0.3, 0.0, 0.0)
}

class EnemyStats extends RefCounted:
	var max_hp: float = 0.0
	var speed: float = 0.0
	var reward: int = 0
	var size: float = 1.0

	func _init(hp: float, spd: float, rwd: int, sz: float = 1.0) -> void:
		max_hp = hp
		speed = spd
		reward = rwd
		size = sz

static func get_enemy_stats(enemy_type: int) -> EnemyStats:
	var _data: Dictionary = {
		EnemyType.ANT: EnemyStats.new(30.0, 60.0, 5, 0.7),
		EnemyType.CATERPILLAR: EnemyStats.new(60.0, 35.0, 8, 1.0),
		EnemyType.BEETLE: EnemyStats.new(120.0, 40.0, 12, 1.2),
		EnemyType.LOCUST: EnemyStats.new(50.0, 80.0, 10, 0.8),
		EnemyType.BOSS_SPIDER: EnemyStats.new(500.0, 25.0, 50, 2.0),
	}
	return _data[enemy_type]

# ========================================
# Wave Configuration
# ========================================

class WaveEntry extends RefCounted:
	var enemy_type: int = 0
	var count: int = 0
	var spawn_interval: float = 0.0
	var delay_before: float = 0.0

	func _init(et: int, c: int, si: float, db: float = 0.0) -> void:
		enemy_type = et
		count = c
		spawn_interval = si
		delay_before = db

class WaveData extends RefCounted:
	var entries: Array[WaveEntry] = []
	var hp_multiplier: float = 1.0
	var speed_multiplier: float = 1.0

static func get_waves() -> Array[WaveData]:
	var waves: Array[WaveData] = []

	# Wave 1: Simple ants
	var w1: WaveData = WaveData.new()
	w1.entries.append(WaveEntry.new(EnemyType.ANT, 8, 1.0))
	waves.append(w1)

	# Wave 2: More ants
	var w2: WaveData = WaveData.new()
	w2.entries.append(WaveEntry.new(EnemyType.ANT, 12, 0.8))
	w2.hp_multiplier = 1.2
	waves.append(w2)

	# Wave 3: Ants and caterpillars
	var w3: WaveData = WaveData.new()
	w3.entries.append(WaveEntry.new(EnemyType.ANT, 6, 0.8))
	w3.entries.append(WaveEntry.new(EnemyType.CATERPILLAR, 4, 1.2, 1.0))
	w3.hp_multiplier = 1.3
	waves.append(w3)

	# Wave 4: Caterpillars
	var w4: WaveData = WaveData.new()
	w4.entries.append(WaveEntry.new(EnemyType.CATERPILLAR, 8, 1.0))
	w4.hp_multiplier = 1.5
	waves.append(w4)

	# Wave 5: Mixed with beetles
	var w5: WaveData = WaveData.new()
	w5.entries.append(WaveEntry.new(EnemyType.ANT, 8, 0.6))
	w5.entries.append(WaveEntry.new(EnemyType.BEETLE, 3, 1.5, 1.0))
	w5.hp_multiplier = 1.6
	waves.append(w5)

	# Wave 6: Locusts appear
	var w6: WaveData = WaveData.new()
	w6.entries.append(WaveEntry.new(EnemyType.LOCUST, 6, 0.7))
	w6.entries.append(WaveEntry.new(EnemyType.ANT, 5, 0.5, 0.5))
	w6.hp_multiplier = 1.8
	waves.append(w6)

	# Wave 7: Heavy beetles
	var w7: WaveData = WaveData.new()
	w7.entries.append(WaveEntry.new(EnemyType.BEETLE, 6, 1.2))
	w7.entries.append(WaveEntry.new(EnemyType.CATERPILLAR, 4, 0.8, 1.0))
	w7.hp_multiplier = 2.0
	waves.append(w7)

	# Wave 8: Fast locusts
	var w8: WaveData = WaveData.new()
	w8.entries.append(WaveEntry.new(EnemyType.LOCUST, 10, 0.5))
	w8.hp_multiplier = 2.0
	w8.speed_multiplier = 1.2
	waves.append(w8)

	# Wave 9: Big mix
	var w9: WaveData = WaveData.new()
	w9.entries.append(WaveEntry.new(EnemyType.BEETLE, 4, 1.0))
	w9.entries.append(WaveEntry.new(EnemyType.LOCUST, 6, 0.6, 0.5))
	w9.entries.append(WaveEntry.new(EnemyType.ANT, 8, 0.4, 0.5))
	w9.hp_multiplier = 2.5
	waves.append(w9)

	# Wave 10: Boss wave
	var w10: WaveData = WaveData.new()
	w10.entries.append(WaveEntry.new(EnemyType.BEETLE, 4, 1.0))
	w10.entries.append(WaveEntry.new(EnemyType.BOSS_SPIDER, 1, 0.0, 2.0))
	w10.entries.append(WaveEntry.new(EnemyType.ANT, 6, 0.5, 1.0))
	w10.hp_multiplier = 2.5
	waves.append(w10)

	# Wave 11
	var w11: WaveData = WaveData.new()
	w11.entries.append(WaveEntry.new(EnemyType.LOCUST, 8, 0.5))
	w11.entries.append(WaveEntry.new(EnemyType.BEETLE, 5, 1.0, 0.5))
	w11.hp_multiplier = 3.0
	w11.speed_multiplier = 1.1
	waves.append(w11)

	# Wave 12: Double boss
	var w12: WaveData = WaveData.new()
	w12.entries.append(WaveEntry.new(EnemyType.CATERPILLAR, 6, 0.6))
	w12.entries.append(WaveEntry.new(EnemyType.BOSS_SPIDER, 2, 3.0, 2.0))
	w12.entries.append(WaveEntry.new(EnemyType.LOCUST, 8, 0.4, 1.0))
	w12.hp_multiplier = 3.5
	waves.append(w12)

	return waves

# ========================================
# Map Layout
# ========================================

## 0=grass, 1=path, 2=buildable, 3=blocked(decoration), 4=start, 5=end
static func get_map_layout() -> Array[Array]:
	return [
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0],
		[4, 1, 1, 1, 1, 0, 0, 0, 0, 2, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0],
		[0, 2, 2, 2, 1, 0, 0, 0, 0, 2, 1, 2, 2, 1, 2, 0, 0, 0, 0, 0],
		[0, 0, 0, 2, 1, 2, 0, 0, 0, 2, 1, 0, 2, 1, 2, 2, 2, 2, 2, 0],
		[0, 0, 0, 2, 1, 2, 2, 1, 1, 1, 1, 0, 2, 1, 1, 1, 1, 1, 1, 5],
		[0, 0, 0, 2, 1, 2, 2, 1, 2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 2, 0],
		[0, 0, 0, 2, 1, 2, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 2, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	]

## Ordered path waypoints (cell coordinates as col,row)
## Path: START→right→down→right→up→right→up→right→down→right→END
static func get_path_points() -> Array[Vector2i]:
	return [
		Vector2i(0, 2),
		Vector2i(4, 2),
		Vector2i(4, 8),
		Vector2i(7, 8),
		Vector2i(7, 5),
		Vector2i(10, 5),
		Vector2i(10, 2),
		Vector2i(13, 2),
		Vector2i(13, 5),
		Vector2i(19, 5),
	]

## Starting gold
const START_GOLD: int = 200

## Starting lives
const START_LIVES: int = 20

## Gold earned per wave completion bonus
const WAVE_CLEAR_BONUS: int = 30
