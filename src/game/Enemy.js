import * as THREE from 'three';
import { createEnemyModel } from './ModelFactory.js';
import { ENEMY_TYPES } from './GameConfig.js';

const _dir = new THREE.Vector3();

export class Enemy {
  constructor(type, pathPoints, scene) {
    const config = ENEMY_TYPES[type];
    this.type = type;
    this.config = config;
    this.maxHp = config.hp;
    this.hp = config.hp;
    this.baseSpeed = config.speed;
    this.speed = config.speed;
    this.reward = config.reward;
    this.armor = config.armor || 0;
    this.isBoss = config.isBoss || false;
    this.alive = true;
    this.reachedEnd = false;

    this.slowTimer = 0;
    this.slowFactor = 1;

    this.pathPoints = pathPoints;
    this.pathIndex = 0;

    this.mesh = new THREE.Group();
    this.mesh.name = 'Enemy_' + type;
    const model = createEnemyModel(type);
    model.scale.setScalar(config.scale);
    this.mesh.add(model);
    this.model = model;

    this.mesh.position.copy(pathPoints[0]);

    this._createHealthBar();

    scene.add(this.mesh);
    this.scene = scene;

    this.bobPhase = Math.random() * Math.PI * 2;
  }

  _createHealthBar() {
    const bgGeo = new THREE.PlaneGeometry(0.5, 0.06);
    const bgMat = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.DoubleSide });
    this.hpBg = new THREE.Mesh(bgGeo, bgMat);
    this.hpBg.position.y = 0.5;
    this.hpBg.rotation.x = -Math.PI / 6;

    const fgGeo = new THREE.PlaneGeometry(0.48, 0.04);
    const fgMat = new THREE.MeshBasicMaterial({ color: 0x44dd44, side: THREE.DoubleSide });
    this.hpFg = new THREE.Mesh(fgGeo, fgMat);
    this.hpFg.position.z = 0.001;
    this.hpBg.add(this.hpFg);

    this.mesh.add(this.hpBg);
  }

  takeDamage(amount, opts = {}) {
    if (!this.alive) return;
    const dmg = Math.max(1, amount - this.armor);
    this.hp -= dmg;

    if (opts.slow && opts.slowFactor && opts.slowDuration) {
      this.slowFactor = opts.slowFactor;
      this.slowTimer = opts.slowDuration;
    }

    if (this.hp <= 0) {
      this.hp = 0;
      this.alive = false;
    }

    const ratio = this.hp / this.maxHp;
    this.hpFg.scale.x = Math.max(0.001, ratio);
    this.hpFg.position.x = -(1 - ratio) * 0.24;
    if (ratio > 0.5) this.hpFg.material.color.setHex(0x44dd44);
    else if (ratio > 0.25) this.hpFg.material.color.setHex(0xdddd44);
    else this.hpFg.material.color.setHex(0xdd4444);
  }

  update(dt) {
    if (!this.alive) return;

    if (this.slowTimer > 0) {
      this.slowTimer -= dt;
      this.speed = this.baseSpeed * this.slowFactor;
      if (this.slowTimer <= 0) {
        this.speed = this.baseSpeed;
        this.slowFactor = 1;
      }
    }

    if (this.pathIndex >= this.pathPoints.length) {
      this.reachedEnd = true;
      this.alive = false;
      return;
    }

    const target = this.pathPoints[this.pathIndex];
    _dir.subVectors(target, this.mesh.position);
    _dir.y = 0;
    const dist = _dir.length();

    if (dist < 0.1) {
      this.pathIndex++;
      return;
    }

    _dir.normalize();
    const move = this.speed * dt;
    this.mesh.position.addScaledVector(_dir, Math.min(move, dist));

    const angle = Math.atan2(_dir.x, _dir.z);
    this.mesh.rotation.y = angle;

    this.bobPhase += dt * 6;
    this.model.position.y = Math.sin(this.bobPhase) * 0.03;
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
