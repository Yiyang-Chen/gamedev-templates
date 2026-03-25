import * as THREE from 'three';
import { TOWER_TYPES } from './GameConfig.js';
import { ModelFactory } from './ModelFactory.js';

export class Tower {
  constructor(typeId, gridCol, gridRow, worldPos) {
    this.typeId = typeId;
    this.config = TOWER_TYPES[typeId];
    this.gridCol = gridCol;
    this.gridRow = gridRow;
    this.level = 0;
    this.totalInvested = this.config.cost;

    const stats = this.config.levels[0];
    this.damage = stats.damage;
    this.range = stats.range;
    this.fireRate = stats.fireRate;
    this.projectileSpeed = stats.projectileSpeed;

    this.fireCooldown = 0;
    this.target = null;

    this.mesh = new THREE.Group();
    this.towerModel = ModelFactory.createTowerModel(typeId, 0);
    this.mesh.add(this.towerModel);
    this.mesh.position.copy(worldPos);
    this.mesh.position.y = 0.05;

    this.rangeIndicator = null;

    this.laserBeam = null;
    this.laserTarget = null;

    this.animTime = Math.random() * Math.PI * 2;
  }

  upgrade() {
    if (this.level >= 2) return false;

    this.level++;
    const stats = this.config.levels[this.level];
    this.damage = stats.damage;
    this.range = stats.range;
    this.fireRate = stats.fireRate;
    this.projectileSpeed = stats.projectileSpeed;

    this.mesh.remove(this.towerModel);
    this.towerModel.traverse(child => {
      if (child.isMesh) {
        child.geometry.dispose();
        if (child.material.dispose) child.material.dispose();
      }
    });

    this.towerModel = ModelFactory.createTowerModel(this.typeId, this.level);
    this.mesh.add(this.towerModel);

    return true;
  }

  getUpgradeCost() {
    if (this.level >= 2) return null;
    return this.config.upgradeCosts[this.level];
  }

  getSellValue() {
    return Math.floor(this.totalInvested * 0.7);
  }

  showRange(show) {
    if (show && !this.rangeIndicator) {
      this.rangeIndicator = ModelFactory.createRangeIndicator(this.range);
      this.mesh.add(this.rangeIndicator);
    } else if (!show && this.rangeIndicator) {
      this.mesh.remove(this.rangeIndicator);
      this.rangeIndicator.geometry.dispose();
      this.rangeIndicator.material.dispose();
      this.rangeIndicator = null;
    }
  }

  findTarget(enemies) {
    let closest = null;
    let closestDist = this.range;

    for (const enemy of enemies) {
      if (!enemy.alive || enemy.reachedEnd) continue;
      const dist = this.mesh.position.distanceTo(enemy.mesh.position);
      if (dist <= this.range && dist < closestDist) {
        closest = enemy;
        closestDist = dist;
      }
    }

    this.target = closest;
    return closest;
  }

  update(delta, enemies) {
    this.animTime += delta;
    this.towerModel.rotation.y += delta * 0.3;

    if (this.fireCooldown > 0) {
      this.fireCooldown -= delta;
    }

    if (this.target && (!this.target.alive || this.target.reachedEnd)) {
      this.target = null;
    }

    if (this.target) {
      const dist = this.mesh.position.distanceTo(this.target.mesh.position);
      if (dist > this.range) {
        this.target = null;
      }
    }

    if (!this.target) {
      this.findTarget(enemies);
    }

    if (this.target) {
      const dir = new THREE.Vector3().subVectors(
        this.target.mesh.position,
        this.mesh.position
      );
      const angle = Math.atan2(dir.x, dir.z);
      this.towerModel.rotation.y = angle;
    }

    if (this.config.attackType === 'laser') {
      return this._updateLaser(delta, enemies);
    }

    return this._updateProjectile(delta);
  }

  _updateProjectile(delta) {
    if (this.target && this.fireCooldown <= 0) {
      this.fireCooldown = 1 / this.fireRate;
      return this._createProjectileData();
    }
    return null;
  }

  _updateLaser(delta, enemies) {
    if (this.target) {
      this.target.takeDamage(this.damage * delta * this.fireRate);
      return { type: 'laser', from: this.mesh.position.clone(), to: this.target.mesh.position.clone(), color: this.config.accentColor };
    }
    return null;
  }

  _createProjectileData() {
    const startPos = this.mesh.position.clone();
    startPos.y += 0.3;

    if (this.config.attackType === 'multi') {
      const projectiles = [];
      const count = this.config.multiCount || 3;
      for (let i = 0; i < count; i++) {
        projectiles.push({
          type: 'projectile',
          towerTypeId: this.typeId,
          attackType: 'single',
          startPos: startPos.clone(),
          target: this.target,
          damage: this.damage,
          speed: this.projectileSpeed,
          delay: i * 0.1,
        });
      }
      return { type: 'multi', projectiles };
    }

    return {
      type: 'projectile',
      towerTypeId: this.typeId,
      attackType: this.config.attackType,
      startPos,
      target: this.target,
      damage: this.damage,
      speed: this.projectileSpeed,
      splashRadius: this.config.splashRadius,
      slowFactor: this.config.slowFactor,
      slowDuration: this.config.slowDuration,
    };
  }

  dispose() {
    this.showRange(false);
    this.mesh.traverse(child => {
      if (child.isMesh) {
        child.geometry.dispose();
        if (child.material.dispose) child.material.dispose();
      }
    });
  }
}
