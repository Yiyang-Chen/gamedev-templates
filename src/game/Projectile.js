import * as THREE from 'three';

const _dir = new THREE.Vector3();

export class Projectile {
  constructor({ startPos, target, speed, damage, color, attackType, splashRadius, slowFactor, slowDuration, scene }) {
    this.target = target;
    this.speed = speed;
    this.damage = damage;
    this.attackType = attackType;
    this.splashRadius = splashRadius || 0;
    this.slowFactor = slowFactor || 1;
    this.slowDuration = slowDuration || 0;
    this.alive = true;
    this.scene = scene;

    const geo = new THREE.SphereGeometry(0.06, 5, 4);
    const mat = new THREE.MeshStandardMaterial({
      color,
      emissive: color,
      emissiveIntensity: 0.4,
      roughness: 0.3,
      flatShading: true,
    });
    this.mesh = new THREE.Mesh(geo, mat);
    this.mesh.position.copy(startPos);
    this.mesh.castShadow = true;
    scene.add(this.mesh);

    this.targetPos = target.mesh.position.clone();
    this.targetPos.y += 0.15;
  }

  update(dt, enemies, particleSystem) {
    if (!this.alive) return;

    if (this.target && this.target.alive) {
      this.targetPos.copy(this.target.mesh.position);
      this.targetPos.y += 0.15;
    }

    _dir.subVectors(this.targetPos, this.mesh.position);
    const dist = _dir.length();

    if (dist < 0.15) {
      this._hit(enemies, particleSystem);
      return;
    }

    _dir.normalize();
    const move = this.speed * dt;
    this.mesh.position.addScaledVector(_dir, Math.min(move, dist));

    if (this.mesh.position.y < -1 || dist > 20) {
      this.alive = false;
    }
  }

  _hit(enemies, particleSystem) {
    this.alive = false;

    if (this.attackType === 'splash' && this.splashRadius > 0) {
      for (const enemy of enemies) {
        if (!enemy.alive) continue;
        const d = enemy.mesh.position.distanceTo(this.mesh.position);
        if (d <= this.splashRadius) {
          const falloff = 1 - (d / this.splashRadius) * 0.5;
          enemy.takeDamage(this.damage * falloff);
        }
      }
      if (particleSystem) {
        particleSystem.emit(this.mesh.position, 12, this.mesh.material.color, 0.8);
      }
    } else {
      if (this.target && this.target.alive) {
        const opts = {};
        if (this.attackType === 'slow') {
          opts.slow = true;
          opts.slowFactor = this.slowFactor;
          opts.slowDuration = this.slowDuration;
        }
        this.target.takeDamage(this.damage, opts);
      }
      if (particleSystem) {
        particleSystem.emit(this.mesh.position, 6, this.mesh.material.color, 0.5);
      }
    }
  }

  dispose() {
    this.scene.remove(this.mesh);
    this.mesh.geometry?.dispose();
    this.mesh.material?.dispose();
  }
}
