export const GRID_SIZE = 1;
export const MAP_COLS = 16;
export const MAP_ROWS = 12;

export const CELL_EMPTY = 0;
export const CELL_PATH = 1;
export const CELL_BUILDABLE = 2;
export const CELL_BLOCKED = 3;
export const CELL_START = 4;
export const CELL_END = 5;

export const TOWER_TYPES = {
  strawberry: {
    name: 'Strawberry',
    nameCN: '草莓',
    cost: 80,
    range: 3.0,
    damage: 10,
    fireRate: 1.0,
    projectileSpeed: 8,
    projectileColor: 0xff3333,
    color: 0xff2244,
    accentColor: 0x44cc44,
    attackType: 'single',
    description: 'Basic shooter, fires seeds',
    upgrades: [
      { cost: 60, damageBonus: 5, rangeBonus: 0.3, fireRateBonus: 0.15 },
      { cost: 120, damageBonus: 8, rangeBonus: 0.5, fireRateBonus: 0.2 },
      { cost: 200, damageBonus: 15, rangeBonus: 0.7, fireRateBonus: 0.3 },
    ],
  },
  watermelon: {
    name: 'Watermelon',
    nameCN: '西瓜',
    cost: 120,
    range: 2.8,
    damage: 20,
    fireRate: 0.6,
    projectileSpeed: 6,
    projectileColor: 0x33cc33,
    color: 0x33aa33,
    accentColor: 0x226622,
    attackType: 'splash',
    splashRadius: 1.5,
    description: 'Splash damage, throws slices',
    upgrades: [
      { cost: 80, damageBonus: 10, rangeBonus: 0.2, fireRateBonus: 0.1 },
      { cost: 160, damageBonus: 15, rangeBonus: 0.4, fireRateBonus: 0.15 },
      { cost: 260, damageBonus: 25, rangeBonus: 0.5, fireRateBonus: 0.2 },
    ],
  },
  lemon: {
    name: 'Lemon',
    nameCN: '柠檬',
    cost: 100,
    range: 3.2,
    damage: 8,
    fireRate: 0.8,
    projectileSpeed: 7,
    projectileColor: 0xffff33,
    color: 0xffee33,
    accentColor: 0xccaa00,
    attackType: 'slow',
    slowFactor: 0.5,
    slowDuration: 2.0,
    description: 'Slows enemies with acid',
    upgrades: [
      { cost: 70, damageBonus: 4, rangeBonus: 0.3, fireRateBonus: 0.1 },
      { cost: 140, damageBonus: 6, rangeBonus: 0.5, fireRateBonus: 0.15 },
      { cost: 220, damageBonus: 10, rangeBonus: 0.6, fireRateBonus: 0.2 },
    ],
  },
  cherry: {
    name: 'Cherry',
    nameCN: '樱桃',
    cost: 90,
    range: 2.5,
    damage: 6,
    fireRate: 2.0,
    projectileSpeed: 12,
    projectileColor: 0xcc0033,
    color: 0xcc0044,
    accentColor: 0x660022,
    attackType: 'single',
    description: 'Rapid fire cherry bombs',
    upgrades: [
      { cost: 60, damageBonus: 3, rangeBonus: 0.2, fireRateBonus: 0.4 },
      { cost: 120, damageBonus: 5, rangeBonus: 0.3, fireRateBonus: 0.6 },
      { cost: 200, damageBonus: 8, rangeBonus: 0.5, fireRateBonus: 0.8 },
    ],
  },
  pineapple: {
    name: 'Pineapple',
    nameCN: '菠萝',
    cost: 150,
    range: 2.2,
    damage: 30,
    fireRate: 0.4,
    projectileSpeed: 5,
    projectileColor: 0xffaa00,
    color: 0xddaa00,
    accentColor: 0x44aa22,
    attackType: 'splash',
    splashRadius: 2.0,
    description: 'Powerful AOE spiky blast',
    upgrades: [
      { cost: 100, damageBonus: 15, rangeBonus: 0.2, fireRateBonus: 0.05 },
      { cost: 200, damageBonus: 25, rangeBonus: 0.3, fireRateBonus: 0.1 },
      { cost: 320, damageBonus: 40, rangeBonus: 0.5, fireRateBonus: 0.15 },
    ],
  },
};

export const ENEMY_TYPES = {
  caterpillar: {
    name: 'Caterpillar',
    nameCN: '毛毛虫',
    hp: 80,
    speed: 1.2,
    reward: 15,
    color: 0x66cc33,
    accentColor: 0x449922,
    scale: 0.35,
  },
  ant: {
    name: 'Ant',
    nameCN: '蚂蚁',
    hp: 40,
    speed: 2.5,
    reward: 10,
    color: 0x443322,
    accentColor: 0x221100,
    scale: 0.25,
  },
  beetle: {
    name: 'Beetle',
    nameCN: '甲虫',
    hp: 120,
    speed: 1.5,
    reward: 20,
    color: 0x335577,
    accentColor: 0x224466,
    scale: 0.35,
    armor: 3,
  },
  ladybug: {
    name: 'Ladybug',
    nameCN: '瓢虫',
    hp: 60,
    speed: 2.2,
    reward: 18,
    color: 0xdd3333,
    accentColor: 0x111111,
    scale: 0.3,
  },
  wasp: {
    name: 'Wasp',
    nameCN: '黄蜂',
    hp: 300,
    speed: 1.8,
    reward: 80,
    color: 0xffcc00,
    accentColor: 0x222222,
    scale: 0.45,
    isBoss: true,
  },
};

export const WAVES = [
  {
    enemies: [
      { type: 'ant', count: 6, interval: 1.0, delay: 0 },
    ],
  },
  {
    enemies: [
      { type: 'ant', count: 8, interval: 0.8, delay: 0 },
      { type: 'caterpillar', count: 3, interval: 1.5, delay: 4 },
    ],
  },
  {
    enemies: [
      { type: 'caterpillar', count: 6, interval: 1.2, delay: 0 },
      { type: 'ant', count: 5, interval: 0.6, delay: 3 },
    ],
  },
  {
    enemies: [
      { type: 'beetle', count: 4, interval: 1.5, delay: 0 },
      { type: 'ant', count: 8, interval: 0.5, delay: 2 },
    ],
  },
  {
    enemies: [
      { type: 'ladybug', count: 6, interval: 1.0, delay: 0 },
      { type: 'caterpillar', count: 4, interval: 1.0, delay: 3 },
    ],
  },
  {
    enemies: [
      { type: 'beetle', count: 6, interval: 1.0, delay: 0 },
      { type: 'ladybug', count: 5, interval: 0.8, delay: 3 },
      { type: 'caterpillar', count: 4, interval: 1.2, delay: 5 },
    ],
  },
  {
    enemies: [
      { type: 'ant', count: 15, interval: 0.3, delay: 0 },
      { type: 'beetle', count: 5, interval: 1.2, delay: 3 },
    ],
  },
  {
    enemies: [
      { type: 'ladybug', count: 8, interval: 0.7, delay: 0 },
      { type: 'beetle', count: 6, interval: 1.0, delay: 3 },
      { type: 'caterpillar', count: 5, interval: 1.0, delay: 5 },
    ],
  },
  {
    enemies: [
      { type: 'beetle', count: 8, interval: 0.8, delay: 0 },
      { type: 'ladybug', count: 8, interval: 0.6, delay: 2 },
      { type: 'ant', count: 10, interval: 0.4, delay: 4 },
    ],
  },
  {
    enemies: [
      { type: 'wasp', count: 1, interval: 2, delay: 0 },
      { type: 'beetle', count: 8, interval: 0.8, delay: 2 },
      { type: 'ladybug', count: 6, interval: 0.7, delay: 4 },
      { type: 'caterpillar', count: 6, interval: 0.8, delay: 6 },
    ],
  },
];

// prettier-ignore
export const MAP_LAYOUT = [
  [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
  [3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3],
  [4,1,1,1,1,2,2,2,2,2,2,1,1,1,2,3],
  [3,2,2,2,1,2,2,2,2,2,2,1,2,1,2,3],
  [3,2,2,2,1,2,2,2,2,2,2,1,2,1,2,3],
  [3,2,2,2,1,1,1,1,1,1,1,1,2,1,2,3],
  [3,2,2,2,2,2,2,2,2,2,2,2,2,1,2,3],
  [3,2,1,1,1,1,1,1,1,1,1,1,1,1,2,3],
  [3,2,1,2,2,2,2,2,2,2,2,2,2,2,2,3],
  [3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,5],
  [3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3],
  [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
];

export const PATH_WAYPOINTS = [
  { col: 0, row: 2 },
  { col: 1, row: 2 },
  { col: 4, row: 2 },
  { col: 4, row: 5 },
  { col: 11, row: 5 },
  { col: 11, row: 2 },
  { col: 13, row: 2 },
  { col: 13, row: 7 },
  { col: 2, row: 7 },
  { col: 2, row: 9 },
  { col: 15, row: 9 },
];

export const STARTING_COINS = 300;
export const STARTING_LIVES = 20;
export const SELL_REFUND_RATIO = 0.6;
