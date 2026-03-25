import * as THREE from 'three';
import { createTowerModel } from './ModelFactory.js';
import { TOWER_TYPES, GRID_SIZE } from './GameConfig.js';
import { Projectile } from './Projectile.js';

const _targetPos = new THREE.Vector3();

export class Tower {
  constructor(type, col, row, gridToWorldFn, scene) {
    this.type = type;
    this.col = col;
    this.row = row;
    this.level = 0;
    this.scene = scene;

    const config = TOWER_TYPES[type];
    this.config = config;
    this.range = config.range;
    this.damage = config.damage;
    this.fireRate = config.fireRate;
    this.projectileSpeed = config.projectileSpeed;
    this.attackType = config.attackType;
    this.splashRadius = config.splashRadius || 0;
    this.slowFactor = config.slowFactor || 1;
    this.slowDuration = config.slowDuration || 0;

    this.fireCooldown = 0;
    this.target = null;
    this.totalCost = config.cost;

    const worldPos = gridToWorldFn(col, row);
    this.position = worldPos.clone();
    this.position.y = 0.05;

    this.mesh = new THREE.Group();
    this.mesh.name = 'Tower_' + type;
    this.mesh.position.copy(this.position);

    this._buildModel();
    this._buildRangeIndicator();

    scene.add(this.mesh);
  }

  _buildModel() {
    if (this.model) {
      this.mesh.remove(this.model);
    }
    this.model = createTowerModel(this.type, this.level);
    this.mesh.add(this.model);
  }

  _buildRangeIndicator() {
    const geo = new THREE.RingGeometry(this.range - 0.05, this.range, 32);
    const mat = new THREE.MeshBasicMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.15,
      side: THREE.DoubleSide,
    });
    this.rangeIndicator = new THREE.Mesh(geo, mat);
    this.rangeIndicator.rotation.x = -Math.PI / 2;
    this.rangeIndicator.position.y = 0.02;
    this.rangeIndicator.visible = false;
    this.mesh.add(this.rangeIndicator);
  }

  showRange(visible) {
    this.rangeIndicator.visible = visible;
  }

  canUpgrade() {
    return this.level < 3;
  }

  getUpgradeCost() {
    if (!this.canUpgrade()) return Infinity;
    return this.config.upgrades[this.level].cost;
  }

  upgrade() {
    if (!this.canUpgrade()) return;
    const upg = this.config.upgrades[this.level];
    this.damage += upg.damageBonus;
    this.range += upg.rangeBonus;
    this.fireRate += upg.fireRateBonus;
    this.totalCost += upg.cost;
    this.level++;

    this._buildModel();

    this.rangeIndicator.geometry.dispose();
    this.rangeIndicator.geometry = new THREE.RingGeometry(this.range - 0.05, this.range, 32);
  }

  getSellValue() {
    return Math.floor(this.totalCost * 0.6);
  }

  findTarget(enemies) {
    let closest = null;
    let closestDist = Infinity;

    for (const enemy of enemies) {
      if (!enemy.alive) continue;
      const dist = this.position.distanceTo(enemy.mesh.position);
      if (dist <= this.range && dist < closestDist) {
        closest = enemy;
        closestDist = dist;
      }
    }

    this.target = closest;
    return closest;
  }

  update(dt, enemies, projectiles) {
    this.fireCooldown -= dt;
    this.model.rotation.y += dt * 0.3;

    this.findTarget(enemies);

    if (this.target && this.fireCooldown <= 0) {
      this._fire(projectiles);
      this.fireCooldown = 1 / this.fireRate;
    }
  }

  _fire(projectiles) {
    if (!this.target) return;

    _targetPos.copy(this.target.mesh.position);
    _targetPos.y += 0.15;

    const startPos = this.position.clone();
    startPos.y += 0.4;

    const proj = new Projectile({
      startPos,
      target: this.target,
      speed: this.projectileSpeed,
      damage: this.damage,
      color: this.config.projectileColor,
      attackType: this.attackType,
      splashRadius: this.splashRadius,
      slowFactor: this.slowFactor,
      slowDuration: this.slowDuration,
      scene: this.scene,
    });

    projectiles.push(proj);
  }

  dispose() {
    this.scene.remove(this.mesh);
    this.mesh.traverse((child) => {
      if (child.isMesh) {
        child.geometry?.dispose();
        child.material?.dispose();
      }
    });
  }
}
