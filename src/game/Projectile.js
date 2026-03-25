import * as THREE from 'three';
import { ModelFactory } from './ModelFactory.js';

export class Projectile {
  constructor(data) {
    this.towerTypeId = data.towerTypeId;
    this.attackType = data.attackType;
    this.target = data.target;
    this.damage = data.damage;
    this.speed = data.speed;
    this.splashRadius = data.splashRadius || 0;
    this.slowFactor = data.slowFactor || 1;
    this.slowDuration = data.slowDuration || 0;
    this.alive = true;
    this.delay = data.delay || 0;

    this.mesh = ModelFactory.createProjectile(this.towerTypeId);
    if (this.mesh) {
      this.mesh.position.copy(data.startPos);
    }

    this.targetPos = data.target ? data.target.getPosition() : data.startPos.clone();
  }

  update(delta, enemies) {
    if (!this.alive) return null;

    if (this.delay > 0) {
      this.delay -= delta;
      return null;
    }

    if (!this.mesh) {
      this.alive = false;
      return null;
    }

    if (this.target && this.target.alive && !this.target.reachedEnd) {
      this.targetPos = this.target.getPosition();
    }

    const dir = new THREE.Vector3().subVectors(this.targetPos, this.mesh.position);
    const dist = dir.length();

    if (dist < 0.15) {
      this.alive = false;
      return this._onHit(enemies);
    }

    dir.normalize();
    const moveAmount = this.speed * delta;
    this.mesh.position.add(dir.multiplyScalar(Math.min(moveAmount, dist)));
    this.mesh.rotation.x += delta * 5;
    this.mesh.rotation.z += delta * 3;

    return null;
  }

  _onHit(enemies) {
    const hitPos = this.mesh.position.clone();

    switch (this.attackType) {
      case 'splash':
        return this._splashHit(enemies, hitPos);
      case 'slow':
        return this._slowHit(enemies, hitPos);
      default:
        if (this.target && this.target.alive) {
          this.target.takeDamage(this.damage);
        }
        return { type: 'hit', position: hitPos };
    }
  }

  _splashHit(enemies, hitPos) {
    const affected = [];
    for (const enemy of enemies) {
      if (!enemy.alive) continue;
      const dist = enemy.mesh.position.distanceTo(hitPos);
      if (dist <= this.splashRadius) {
        enemy.takeDamage(this.damage * (1 - dist / (this.splashRadius * 1.5)));
        affected.push(enemy);
      }
    }
    return { type: 'splash', position: hitPos, radius: this.splashRadius, affected };
  }

  _slowHit(enemies, hitPos) {
    if (this.target && this.target.alive) {
      this.target.takeDamage(this.damage);
      this.target.applySlow(this.slowFactor, this.slowDuration);
    }
    return { type: 'slow', position: hitPos };
  }

  dispose() {
    if (this.mesh) {
      this.mesh.traverse(child => {
        if (child.isMesh) {
          child.geometry.dispose();
          if (child.material.dispose) child.material.dispose();
        }
      });
    }
  }
}
