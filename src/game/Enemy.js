import * as THREE from 'three';
import { ENEMY_TYPES } from './GameConfig.js';
import { ModelFactory } from './ModelFactory.js';

export class Enemy {
  constructor(typeId, waypoints, healthMultiplier = 1.0) {
    const config = ENEMY_TYPES[typeId];
    this.typeId = typeId;
    this.config = config;
    this.maxHealth = config.health * healthMultiplier;
    this.health = this.maxHealth;
    this.baseSpeed = config.speed;
    this.speed = config.speed;
    this.reward = config.reward;
    this.alive = true;
    this.reachedEnd = false;

    this.waypoints = waypoints.map(w => w.clone());
    this.waypointIndex = 0;

    this.slowTimer = 0;
    this.slowFactor = 1.0;

    this.mesh = ModelFactory.createEnemyModel(typeId);
    this.mesh.position.copy(this.waypoints[0]);
    this.mesh.position.y = 0.05;

    this._createHealthBar();

    this.bobTime = Math.random() * Math.PI * 2;
  }

  _createHealthBar() {
    const barGroup = new THREE.Group();

    const bgGeo = new THREE.PlaneGeometry(0.5, 0.08);
    const bgMat = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.DoubleSide });
    const bg = new THREE.Mesh(bgGeo, bgMat);
    barGroup.add(bg);

    const fgGeo = new THREE.PlaneGeometry(0.48, 0.06);
    const fgMat = new THREE.MeshBasicMaterial({ color: 0x44dd44, side: THREE.DoubleSide });
    this.healthBarFg = new THREE.Mesh(fgGeo, fgMat);
    barGroup.add(this.healthBarFg);

    barGroup.position.y = this.config.scale * 1.2;
    barGroup.rotation.x = -0.3;
    this.healthBar = barGroup;
    this.mesh.add(barGroup);
  }

  takeDamage(amount) {
    this.health -= amount;
    if (this.health <= 0) {
      this.health = 0;
      this.alive = false;
    }
    const ratio = this.health / this.maxHealth;
    this.healthBarFg.scale.x = Math.max(ratio, 0.001);
    this.healthBarFg.position.x = -(0.24 * (1 - ratio));

    if (ratio > 0.5) {
      this.healthBarFg.material.color.setHex(0x44dd44);
    } else if (ratio > 0.25) {
      this.healthBarFg.material.color.setHex(0xdddd44);
    } else {
      this.healthBarFg.material.color.setHex(0xdd4444);
    }
  }

  applySlow(factor, duration) {
    this.slowFactor = factor;
    this.slowTimer = duration;
  }

  update(delta) {
    if (!this.alive || this.reachedEnd) return;

    if (this.slowTimer > 0) {
      this.slowTimer -= delta;
      this.speed = this.baseSpeed * this.slowFactor;
      if (this.slowTimer <= 0) {
        this.speed = this.baseSpeed;
        this.slowFactor = 1.0;
      }
    }

    const target = this.waypoints[this.waypointIndex];
    const pos = this.mesh.position;
    const dir = new THREE.Vector3(target.x - pos.x, 0, target.z - pos.z);
    const dist = dir.length();

    if (dist < 0.1) {
      this.waypointIndex++;
      if (this.waypointIndex >= this.waypoints.length) {
        this.reachedEnd = true;
        this.alive = false;
        return;
      }
    } else {
      dir.normalize();
      const moveAmount = this.speed * delta;
      if (moveAmount >= dist) {
        pos.x = target.x;
        pos.z = target.z;
      } else {
        pos.x += dir.x * moveAmount;
        pos.z += dir.z * moveAmount;
      }

      const angle = Math.atan2(dir.x, dir.z);
      this.mesh.rotation.y = angle;
    }

    this.bobTime += delta * 4;
    pos.y = 0.05 + Math.sin(this.bobTime) * 0.03;

    this.healthBar.lookAt(
      this.mesh.position.x,
      this.mesh.position.y + 5,
      this.mesh.position.z + 5
    );
  }

  getPosition() {
    return this.mesh.position.clone();
  }

  dispose() {
    this.mesh.traverse(child => {
      if (child.isMesh) {
        child.geometry.dispose();
        if (child.material.dispose) child.material.dispose();
      }
    });
  }
}
