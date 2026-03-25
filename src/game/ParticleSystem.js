import * as THREE from 'three';

class Particle {
  constructor(mesh) {
    this.mesh = mesh;
    this.velocity = new THREE.Vector3();
    this.life = 0;
    this.maxLife = 1;
    this.active = false;
  }
}

export class ParticleSystem {
  constructor(scene, poolSize = 200) {
    this.scene = scene;
    this.particles = [];

    const geo = new THREE.SphereGeometry(0.03, 4, 3);
    for (let i = 0; i < poolSize; i++) {
      const mat = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 1,
      });
      const mesh = new THREE.Mesh(geo, mat);
      mesh.visible = false;
      scene.add(mesh);
      this.particles.push(new Particle(mesh));
    }
  }

  emit(position, count, color, duration = 0.6) {
    let emitted = 0;
    for (const p of this.particles) {
      if (p.active) continue;
      if (emitted >= count) break;

      p.active = true;
      p.life = 0;
      p.maxLife = duration * (0.5 + Math.random() * 0.5);
      p.mesh.position.copy(position);
      p.mesh.material.color.copy(color);
      p.mesh.material.opacity = 1;
      p.mesh.visible = true;

      const spread = 2;
      p.velocity.set(
        (Math.random() - 0.5) * spread,
        Math.random() * spread * 0.8 + 0.5,
        (Math.random() - 0.5) * spread
      );

      emitted++;
    }
  }

  emitAt(position, count, hexColor, duration = 0.6) {
    const c = new THREE.Color(hexColor);
    this.emit(position, count, c, duration);
  }

  update(dt) {
    for (const p of this.particles) {
      if (!p.active) continue;

      p.life += dt;
      if (p.life >= p.maxLife) {
        p.active = false;
        p.mesh.visible = false;
        continue;
      }

      p.velocity.y -= 3 * dt;
      p.mesh.position.addScaledVector(p.velocity, dt);

      const ratio = 1 - p.life / p.maxLife;
      p.mesh.material.opacity = ratio;
      const s = 0.5 + ratio * 0.5;
      p.mesh.scale.setScalar(s);
    }
  }

  dispose() {
    for (const p of this.particles) {
      this.scene.remove(p.mesh);
      p.mesh.geometry?.dispose();
      p.mesh.material?.dispose();
    }
  }
}
