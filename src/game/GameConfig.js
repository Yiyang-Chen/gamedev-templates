export const TILE_SIZE = 1.0;
export const GRID_COLS = 16;
export const GRID_ROWS = 12;

export const TILE_TYPES = {
  EMPTY: 0,
  PATH: 1,
  BUILDABLE: 2,
  BLOCKED: 3,
};

export const TOWER_TYPES = {
  WATERMELON: {
    id: 'watermelon',
    name: '西瓜射手',
    cost: 80,
    color: 0x2d8b46,
    accentColor: 0xd4483b,
    attackType: 'single',
    levels: [
      { damage: 10, range: 3.0, fireRate: 1.0, projectileSpeed: 6 },
      { damage: 18, range: 3.5, fireRate: 1.2, projectileSpeed: 7 },
      { damage: 30, range: 4.0, fireRate: 1.5, projectileSpeed: 8 },
    ],
    upgradeCosts: [100, 160],
    description: '发射西瓜子弹，稳定输出',
  },
  STRAWBERRY: {
    id: 'strawberry',
    name: '草莓炸弹',
    cost: 120,
    color: 0xe84057,
    accentColor: 0xffdd44,
    attackType: 'splash',
    splashRadius: 1.2,
    levels: [
      { damage: 15, range: 2.5, fireRate: 0.6, projectileSpeed: 5 },
      { damage: 25, range: 3.0, fireRate: 0.7, projectileSpeed: 5.5 },
      { damage: 40, range: 3.5, fireRate: 0.8, projectileSpeed: 6 },
    ],
    upgradeCosts: [140, 200],
    description: '范围爆炸伤害，适合对付密集敌人',
  },
  BLUEBERRY: {
    id: 'blueberry',
    name: '蓝莓冰冻',
    cost: 100,
    color: 0x4466bb,
    accentColor: 0xaaddff,
    attackType: 'slow',
    slowFactor: 0.4,
    slowDuration: 2.0,
    levels: [
      { damage: 5, range: 3.0, fireRate: 0.8, projectileSpeed: 5 },
      { damage: 10, range: 3.5, fireRate: 1.0, projectileSpeed: 6 },
      { damage: 18, range: 4.0, fireRate: 1.2, projectileSpeed: 7 },
    ],
    upgradeCosts: [120, 180],
    description: '减速敌人，控制节奏',
  },
  ORANGE: {
    id: 'orange',
    name: '橙子激光',
    cost: 150,
    color: 0xff8c00,
    accentColor: 0xffdd00,
    attackType: 'laser',
    levels: [
      { damage: 8, range: 4.0, fireRate: 3.0, projectileSpeed: 999 },
      { damage: 14, range: 4.5, fireRate: 3.5, projectileSpeed: 999 },
      { damage: 22, range: 5.0, fireRate: 4.0, projectileSpeed: 999 },
    ],
    upgradeCosts: [180, 250],
    description: '持续激光照射，穿透攻击',
  },
  GRAPE: {
    id: 'grape',
    name: '葡萄连射',
    cost: 90,
    color: 0x8844aa,
    accentColor: 0xcc88ee,
    attackType: 'multi',
    multiCount: 3,
    levels: [
      { damage: 6, range: 3.0, fireRate: 1.5, projectileSpeed: 8 },
      { damage: 10, range: 3.5, fireRate: 2.0, projectileSpeed: 9 },
      { damage: 16, range: 4.0, fireRate: 2.5, projectileSpeed: 10 },
    ],
    upgradeCosts: [110, 170],
    description: '连续发射多颗葡萄弹',
  },
};

export const ENEMY_TYPES = {
  ANT: {
    id: 'ant',
    name: '小蚂蚁',
    color: 0x444444,
    health: 30,
    speed: 1.8,
    reward: 10,
    scale: 0.6,
  },
  CATERPILLAR: {
    id: 'caterpillar',
    name: '毛毛虫',
    color: 0x66aa22,
    health: 60,
    speed: 1.2,
    reward: 20,
    scale: 0.7,
  },
  BEETLE: {
    id: 'beetle',
    name: '甲壳虫',
    color: 0x885522,
    health: 120,
    speed: 0.8,
    reward: 35,
    scale: 0.8,
  },
  LADYBUG: {
    id: 'ladybug',
    name: '瓢虫',
    color: 0xee3333,
    health: 80,
    speed: 2.2,
    reward: 25,
    scale: 0.65,
  },
  WASP: {
    id: 'wasp',
    name: '黄蜂',
    color: 0xffcc00,
    health: 50,
    speed: 3.0,
    reward: 30,
    scale: 0.55,
  },
  BOSS_STAG: {
    id: 'boss_stag',
    name: '锹形虫BOSS',
    color: 0x553300,
    health: 500,
    speed: 0.6,
    reward: 200,
    scale: 1.2,
  },
};

export const WAVES = [
  { enemies: [{ type: 'ANT', count: 8, interval: 0.8 }] },
  { enemies: [{ type: 'ANT', count: 10, interval: 0.7 }, { type: 'CATERPILLAR', count: 3, interval: 1.2 }] },
  { enemies: [{ type: 'CATERPILLAR', count: 8, interval: 0.9 }, { type: 'ANT', count: 5, interval: 0.5 }] },
  { enemies: [{ type: 'BEETLE', count: 4, interval: 1.5 }, { type: 'ANT', count: 12, interval: 0.5 }] },
  { enemies: [{ type: 'LADYBUG', count: 8, interval: 0.6 }, { type: 'CATERPILLAR', count: 5, interval: 1.0 }] },
  { enemies: [{ type: 'WASP', count: 10, interval: 0.5 }, { type: 'BEETLE', count: 3, interval: 1.5 }] },
  { enemies: [{ type: 'BEETLE', count: 6, interval: 1.0 }, { type: 'LADYBUG', count: 8, interval: 0.5 }, { type: 'ANT', count: 10, interval: 0.4 }] },
  { enemies: [{ type: 'WASP', count: 15, interval: 0.4 }, { type: 'CATERPILLAR', count: 8, interval: 0.8 }] },
  { enemies: [{ type: 'BEETLE', count: 10, interval: 0.8 }, { type: 'WASP', count: 8, interval: 0.5 }, { type: 'LADYBUG', count: 6, interval: 0.6 }] },
  { enemies: [{ type: 'BOSS_STAG', count: 1, interval: 0 }, { type: 'BEETLE', count: 6, interval: 1.0 }, { type: 'WASP', count: 10, interval: 0.4 }] },
];

export const MAP_LAYOUT = [
  [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
  [1, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 3],
  [3, 2, 1, 2, 0, 0, 2, 2, 2, 0, 0, 0, 2, 1, 1, 3],
  [3, 2, 1, 2, 0, 0, 2, 1, 1, 1, 1, 0, 0, 1, 2, 3],
  [3, 0, 1, 1, 1, 0, 0, 1, 2, 2, 1, 0, 0, 1, 2, 3],
  [3, 0, 2, 2, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 3],
  [3, 0, 0, 2, 1, 0, 0, 1, 0, 0, 0, 2, 2, 0, 0, 3],
  [3, 0, 0, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 3],
  [3, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 3],
  [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3],
  [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3],
  [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
];

export const PATH_WAYPOINTS = [
  { col: 0, row: 1 },
  { col: 2, row: 1 },
  { col: 2, row: 4 },
  { col: 4, row: 4 },
  { col: 4, row: 7 },
  { col: 7, row: 7 },
  { col: 7, row: 3 },
  { col: 10, row: 3 },
  { col: 10, row: 5 },
  { col: 13, row: 5 },
  { col: 13, row: 2 },
  { col: 14, row: 2 },
];

export const PLAYER_START_GOLD = 300;
export const PLAYER_START_LIVES = 20;
