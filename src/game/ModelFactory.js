import * as THREE from 'three';
import { TOWER_TYPES, ENEMY_TYPES } from './GameConfig.js';

export class ModelFactory {
  static createTowerModel(towerTypeId, level = 0) {
    const config = TOWER_TYPES[towerTypeId];
    if (!config) return new THREE.Group();

    const group = new THREE.Group();
    const scale = 0.35 + level * 0.05;

    switch (config.id) {
      case 'watermelon':
        group.add(ModelFactory._createWatermelon(config, level, scale));
        break;
      case 'strawberry':
        group.add(ModelFactory._createStrawberry(config, level, scale));
        break;
      case 'blueberry':
        group.add(ModelFactory._createBlueberry(config, level, scale));
        break;
      case 'orange':
        group.add(ModelFactory._createOrange(config, level, scale));
        break;
      case 'grape':
        group.add(ModelFactory._createGrape(config, level, scale));
        break;
    }

    if (level > 0) {
      const crownGeo = new THREE.ConeGeometry(0.08 * level, 0.15 * level, 5);
      const crownMat = new THREE.MeshStandardMaterial({ color: 0xffd700, metalness: 0.6, roughness: 0.3 });
      const crown = new THREE.Mesh(crownGeo, crownMat);
      crown.position.y = scale * 2.0 + 0.1;
      group.add(crown);
    }

    group.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    });

    return group;
  }

  static _createWatermelon(config, level, scale) {
    const g = new THREE.Group();
    const bodyGeo = new THREE.SphereGeometry(scale, 16, 12);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: config.color,
      roughness: 0.4,
      metalness: 0.1,
    });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = scale;
    g.add(body);

    for (let i = 0; i < 6; i++) {
      const stripeGeo = new THREE.TorusGeometry(scale * 0.95, 0.015, 4, 16);
      const stripeMat = new THREE.MeshStandardMaterial({ color: 0x1a5c2e });
      const stripe = new THREE.Mesh(stripeGeo, stripeMat);
      stripe.position.y = scale;
      stripe.rotation.y = (i / 6) * Math.PI;
      stripe.rotation.x = Math.PI / 2;
      g.add(stripe);
    }

    const leafGeo = new THREE.ConeGeometry(0.06, 0.15, 4);
    const leafMat = new THREE.MeshStandardMaterial({ color: 0x33aa33 });
    const leaf = new THREE.Mesh(leafGeo, leafMat);
    leaf.position.y = scale * 2 + 0.05;
    g.add(leaf);

    const baseGeo = new THREE.CylinderGeometry(scale * 0.6, scale * 0.8, 0.1, 8);
    const baseMat = new THREE.MeshStandardMaterial({ color: 0x8B6914 });
    const base = new THREE.Mesh(baseGeo, baseMat);
    base.position.y = 0.05;
    g.add(base);

    return g;
  }

  static _createStrawberry(config, level, scale) {
    const g = new THREE.Group();
    const bodyGeo = new THREE.ConeGeometry(scale * 0.8, scale * 2, 8);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: config.color,
      roughness: 0.5,
    });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = scale;
    body.rotation.x = Math.PI;
    body.position.y = scale * 1.5;
    g.add(body);

    for (let i = 0; i < 8 + level * 3; i++) {
      const seedGeo = new THREE.SphereGeometry(0.02, 4, 4);
      const seedMat = new THREE.MeshStandardMaterial({ color: config.accentColor });
      const seed = new THREE.Mesh(seedGeo, seedMat);
      const angle = Math.random() * Math.PI * 2;
      const h = 0.2 + Math.random() * scale * 1.2;
      seed.position.set(
        Math.cos(angle) * scale * 0.5 * (h / (scale * 1.5)),
        scale * 0.5 + h * 0.5,
        Math.sin(angle) * scale * 0.5 * (h / (scale * 1.5))
      );
      g.add(seed);
    }

    for (let i = 0; i < 3; i++) {
      const leafGeo = new THREE.PlaneGeometry(0.15, 0.08);
      const leafMat = new THREE.MeshStandardMaterial({ color: 0x33aa33, side: THREE.DoubleSide });
      const leaf = new THREE.Mesh(leafGeo, leafMat);
      leaf.position.y = scale * 2 + 0.05;
      leaf.rotation.y = (i / 3) * Math.PI * 2;
      leaf.rotation.x = -0.5;
      g.add(leaf);
    }

    return g;
  }

  static _createBlueberry(config, level, scale) {
    const g = new THREE.Group();

    const bodyGeo = new THREE.SphereGeometry(scale * 0.85, 12, 10);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: config.color,
      roughness: 0.3,
      metalness: 0.2,
    });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = scale;
    g.add(body);

    const frostGeo = new THREE.SphereGeometry(scale * 0.95, 12, 10);
    const frostMat = new THREE.MeshStandardMaterial({
      color: config.accentColor,
      transparent: true,
      opacity: 0.2 + level * 0.1,
      roughness: 0.1,
    });
    const frost = new THREE.Mesh(frostGeo, frostMat);
    frost.position.y = scale;
    g.add(frost);

    for (let i = 0; i < 3 + level; i++) {
      const crystalGeo = new THREE.OctahedronGeometry(0.05 + level * 0.02, 0);
      const crystalMat = new THREE.MeshStandardMaterial({
        color: 0xaaddff,
        transparent: true,
        opacity: 0.7,
        metalness: 0.8,
        roughness: 0.1,
      });
      const crystal = new THREE.Mesh(crystalGeo, crystalMat);
      const a = (i / (3 + level)) * Math.PI * 2;
      crystal.position.set(
        Math.cos(a) * scale * 0.7,
        scale + 0.2,
        Math.sin(a) * scale * 0.7
      );
      crystal.rotation.set(Math.random(), Math.random(), Math.random());
      g.add(crystal);
    }

    return g;
  }

  static _createOrange(config, level, scale) {
    const g = new THREE.Group();

    const bodyGeo = new THREE.SphereGeometry(scale, 16, 12);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: config.color,
      roughness: 0.6,
      metalness: 0.0,
    });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = scale;
    g.add(body);

    const navelGeo = new THREE.CircleGeometry(scale * 0.15, 8);
    const navelMat = new THREE.MeshStandardMaterial({ color: 0xcc6600, side: THREE.DoubleSide });
    const navel = new THREE.Mesh(navelGeo, navelMat);
    navel.position.set(0, scale, scale + 0.01);
    g.add(navel);

    const stemGeo = new THREE.CylinderGeometry(0.02, 0.03, 0.1, 6);
    const stemMat = new THREE.MeshStandardMaterial({ color: 0x336600 });
    const stem = new THREE.Mesh(stemGeo, stemMat);
    stem.position.y = scale * 2 + 0.02;
    g.add(stem);

    const leafGeo = new THREE.PlaneGeometry(0.12, 0.06);
    const leafMat = new THREE.MeshStandardMaterial({ color: 0x33aa33, side: THREE.DoubleSide });
    const leaf = new THREE.Mesh(leafGeo, leafMat);
    leaf.position.set(0.05, scale * 2 + 0.05, 0);
    leaf.rotation.z = -0.3;
    g.add(leaf);

    if (level > 0) {
      const glowGeo = new THREE.SphereGeometry(scale * 1.1, 16, 12);
      const glowMat = new THREE.MeshStandardMaterial({
        color: config.accentColor,
        transparent: true,
        opacity: 0.15 * level,
        emissive: config.accentColor,
        emissiveIntensity: 0.3 * level,
      });
      const glow = new THREE.Mesh(glowGeo, glowMat);
      glow.position.y = scale;
      g.add(glow);
    }

    return g;
  }

  static _createGrape(config, level, scale) {
    const g = new THREE.Group();
    const grapePositions = [
      [0, 0, 0],
      [-0.12, 0.15, 0], [0.12, 0.15, 0],
      [-0.06, 0.3, 0.08], [0.06, 0.3, -0.08],
      [0, 0.45, 0],
    ];

    const grapeRadius = scale * 0.35;
    grapePositions.forEach(([x, y, z]) => {
      const gGeo = new THREE.SphereGeometry(grapeRadius + level * 0.02, 8, 6);
      const gMat = new THREE.MeshStandardMaterial({
        color: config.color,
        roughness: 0.3,
        metalness: 0.15,
      });
      const grape = new THREE.Mesh(gGeo, gMat);
      grape.position.set(x, y + grapeRadius + 0.05, z);
      g.add(grape);
    });

    const stemGeo = new THREE.CylinderGeometry(0.015, 0.02, 0.2, 4);
    const stemMat = new THREE.MeshStandardMaterial({ color: 0x336600 });
    const stem = new THREE.Mesh(stemGeo, stemMat);
    stem.position.y = 0.7;
    g.add(stem);

    return g;
  }

  static createEnemyModel(enemyTypeId) {
    const config = ENEMY_TYPES[enemyTypeId];
    if (!config) return new THREE.Group();

    const group = new THREE.Group();
    const s = config.scale;

    switch (config.id) {
      case 'ant':
        group.add(ModelFactory._createAnt(config, s));
        break;
      case 'caterpillar':
        group.add(ModelFactory._createCaterpillar(config, s));
        break;
      case 'beetle':
        group.add(ModelFactory._createBeetle(config, s));
        break;
      case 'ladybug':
        group.add(ModelFactory._createLadybug(config, s));
        break;
      case 'wasp':
        group.add(ModelFactory._createWasp(config, s));
        break;
      case 'boss_stag':
        group.add(ModelFactory._createBossStag(config, s));
        break;
    }

    group.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
      }
    });

    return group;
  }

  static _createAnt(config, s) {
    const g = new THREE.Group();
    const mat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.5 });

    const headGeo = new THREE.SphereGeometry(s * 0.2, 8, 6);
    const head = new THREE.Mesh(headGeo, mat);
    head.position.set(0, s * 0.25, s * 0.25);
    g.add(head);

    const bodyGeo = new THREE.SphereGeometry(s * 0.25, 8, 6);
    const body = new THREE.Mesh(bodyGeo, mat);
    body.position.set(0, s * 0.25, 0);
    g.add(body);

    const abdGeo = new THREE.SphereGeometry(s * 0.3, 8, 6);
    const abd = new THREE.Mesh(abdGeo, mat);
    abd.position.set(0, s * 0.3, -s * 0.35);
    g.add(abd);

    const eyeMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
    [-1, 1].forEach(side => {
      const eyeGeo = new THREE.SphereGeometry(0.04, 6, 6);
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(side * 0.08, s * 0.35, s * 0.38);
      g.add(eye);
      const pupilGeo = new THREE.SphereGeometry(0.02, 4, 4);
      const pupil = new THREE.Mesh(pupilGeo, new THREE.MeshStandardMaterial({ color: 0x000000 }));
      pupil.position.set(side * 0.08, s * 0.35, s * 0.42);
      g.add(pupil);
    });

    for (let i = 0; i < 6; i++) {
      const legGeo = new THREE.CylinderGeometry(0.01, 0.01, s * 0.3, 4);
      const leg = new THREE.Mesh(legGeo, mat);
      const side = i < 3 ? -1 : 1;
      const idx = i % 3;
      leg.position.set(side * s * 0.2, 0, (idx - 1) * s * 0.2);
      leg.rotation.z = side * 0.8;
      g.add(leg);
    }

    return g;
  }

  static _createCaterpillar(config, s) {
    const g = new THREE.Group();
    const mat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.4 });

    for (let i = 0; i < 5; i++) {
      const segGeo = new THREE.SphereGeometry(s * 0.22, 8, 6);
      const seg = new THREE.Mesh(segGeo, mat);
      seg.position.set(0, s * 0.22 + Math.sin(i * 0.5) * 0.05, -i * s * 0.3);
      g.add(seg);
    }

    const headGeo = new THREE.SphereGeometry(s * 0.25, 8, 6);
    const headMat = new THREE.MeshStandardMaterial({ color: 0x88cc22 });
    const head = new THREE.Mesh(headGeo, headMat);
    head.position.set(0, s * 0.3, s * 0.2);
    g.add(head);

    const eyeMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
    [-1, 1].forEach(side => {
      const eyeGeo = new THREE.SphereGeometry(0.05, 6, 6);
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(side * 0.1, s * 0.4, s * 0.35);
      g.add(eye);
      const pupilGeo = new THREE.SphereGeometry(0.025, 4, 4);
      const pupil = new THREE.Mesh(pupilGeo, new THREE.MeshStandardMaterial({ color: 0x111111 }));
      pupil.position.set(side * 0.1, s * 0.4, s * 0.4);
      g.add(pupil);
    });

    [-1, 1].forEach(side => {
      const antGeo = new THREE.CylinderGeometry(0.01, 0.01, 0.15, 4);
      const antMat = new THREE.MeshStandardMaterial({ color: 0x88cc22 });
      const ant = new THREE.Mesh(antGeo, antMat);
      ant.position.set(side * 0.06, s * 0.55, s * 0.25);
      ant.rotation.z = side * 0.3;
      g.add(ant);
    });

    return g;
  }

  static _createBeetle(config, s) {
    const g = new THREE.Group();
    const mat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.3, metalness: 0.2 });

    const shellGeo = new THREE.SphereGeometry(s * 0.4, 12, 8);
    shellGeo.scale(1, 0.6, 1.2);
    const shell = new THREE.Mesh(shellGeo, mat);
    shell.position.y = s * 0.3;
    g.add(shell);

    const headGeo = new THREE.SphereGeometry(s * 0.2, 8, 6);
    const head = new THREE.Mesh(headGeo, mat);
    head.position.set(0, s * 0.25, s * 0.4);
    g.add(head);

    const eyeMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
    [-1, 1].forEach(side => {
      const eyeGeo = new THREE.SphereGeometry(0.04, 6, 6);
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(side * 0.1, s * 0.35, s * 0.5);
      g.add(eye);
    });

    return g;
  }

  static _createLadybug(config, s) {
    const g = new THREE.Group();

    const shellGeo = new THREE.SphereGeometry(s * 0.35, 12, 8);
    shellGeo.scale(1, 0.7, 1);
    const shellMat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.3 });
    const shell = new THREE.Mesh(shellGeo, shellMat);
    shell.position.y = s * 0.25;
    g.add(shell);

    for (let i = 0; i < 6; i++) {
      const dotGeo = new THREE.SphereGeometry(0.04, 6, 6);
      const dotMat = new THREE.MeshStandardMaterial({ color: 0x111111 });
      const dot = new THREE.Mesh(dotGeo, dotMat);
      const a = (i / 6) * Math.PI * 2;
      dot.position.set(
        Math.cos(a) * s * 0.2,
        s * 0.45,
        Math.sin(a) * s * 0.2
      );
      g.add(dot);
    }

    const headGeo = new THREE.SphereGeometry(s * 0.15, 8, 6);
    const headMat = new THREE.MeshStandardMaterial({ color: 0x222222 });
    const head = new THREE.Mesh(headGeo, headMat);
    head.position.set(0, s * 0.2, s * 0.35);
    g.add(head);

    return g;
  }

  static _createWasp(config, s) {
    const g = new THREE.Group();

    const bodyGeo = new THREE.CapsuleGeometry(s * 0.15, s * 0.3, 4, 8);
    const bodyMat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.4 });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = s * 0.3;
    body.rotation.x = Math.PI / 2;
    g.add(body);

    const stripe1 = new THREE.Mesh(
      new THREE.TorusGeometry(s * 0.16, 0.02, 4, 8),
      new THREE.MeshStandardMaterial({ color: 0x222222 })
    );
    stripe1.position.set(0, s * 0.3, 0);
    stripe1.rotation.x = Math.PI / 2;
    g.add(stripe1);

    [-1, 1].forEach(side => {
      const wingGeo = new THREE.PlaneGeometry(s * 0.4, s * 0.15);
      const wingMat = new THREE.MeshStandardMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.4,
        side: THREE.DoubleSide,
      });
      const wing = new THREE.Mesh(wingGeo, wingMat);
      wing.position.set(side * s * 0.25, s * 0.45, 0);
      wing.rotation.z = side * 0.3;
      g.add(wing);
    });

    const stingGeo = new THREE.ConeGeometry(0.02, 0.1, 4);
    const stingMat = new THREE.MeshStandardMaterial({ color: 0x222222 });
    const sting = new THREE.Mesh(stingGeo, stingMat);
    sting.position.set(0, s * 0.3, -s * 0.35);
    sting.rotation.x = Math.PI / 2;
    g.add(sting);

    return g;
  }

  static _createBossStag(config, s) {
    const g = new THREE.Group();
    const mat = new THREE.MeshStandardMaterial({ color: config.color, roughness: 0.3, metalness: 0.3 });

    const bodyGeo = new THREE.SphereGeometry(s * 0.5, 12, 8);
    bodyGeo.scale(1, 0.7, 1.3);
    const body = new THREE.Mesh(bodyGeo, mat);
    body.position.y = s * 0.4;
    g.add(body);

    const headGeo = new THREE.SphereGeometry(s * 0.3, 10, 8);
    const head = new THREE.Mesh(headGeo, mat);
    head.position.set(0, s * 0.35, s * 0.55);
    g.add(head);

    [-1, 1].forEach(side => {
      const hornGeo = new THREE.ConeGeometry(0.04, s * 0.5, 6);
      const horn = new THREE.Mesh(hornGeo, mat);
      horn.position.set(side * s * 0.2, s * 0.5, s * 0.7);
      horn.rotation.z = side * -0.4;
      horn.rotation.x = -0.5;
      g.add(horn);
    });

    const eyeMat = new THREE.MeshStandardMaterial({ color: 0xff0000, emissive: 0xff0000, emissiveIntensity: 0.5 });
    [-1, 1].forEach(side => {
      const eyeGeo = new THREE.SphereGeometry(0.06, 6, 6);
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(side * 0.15, s * 0.5, s * 0.75);
      g.add(eye);
    });

    return g;
  }

  static createProjectile(towerTypeId) {
    const config = TOWER_TYPES[towerTypeId];
    if (!config) return new THREE.Mesh(new THREE.SphereGeometry(0.05), new THREE.MeshStandardMaterial({ color: 0xff0000 }));

    const mat = new THREE.MeshStandardMaterial({
      color: config.accentColor || config.color,
      emissive: config.accentColor || config.color,
      emissiveIntensity: 0.5,
    });

    let mesh;
    switch (config.attackType) {
      case 'splash':
        mesh = new THREE.Mesh(new THREE.SphereGeometry(0.08, 8, 6), mat);
        break;
      case 'slow':
        mesh = new THREE.Mesh(new THREE.OctahedronGeometry(0.07, 0), mat);
        break;
      case 'laser':
        return null;
      case 'multi': {
        const geo = new THREE.SphereGeometry(0.05, 6, 4);
        mesh = new THREE.Mesh(geo, mat);
        break;
      }
      default:
        mesh = new THREE.Mesh(new THREE.SphereGeometry(0.06, 8, 6), mat);
    }

    mesh.castShadow = true;
    return mesh;
  }

  static createRangeIndicator(range) {
    const geo = new THREE.RingGeometry(range - 0.02, range, 32);
    const mat = new THREE.MeshBasicMaterial({
      color: 0x44ff44,
      transparent: true,
      opacity: 0.3,
      side: THREE.DoubleSide,
    });
    const ring = new THREE.Mesh(geo, mat);
    ring.rotation.x = -Math.PI / 2;
    ring.position.y = 0.02;
    return ring;
  }

  static createSplashEffect(position, radius, color = 0xff4444) {
    const geo = new THREE.RingGeometry(0.01, radius, 16);
    const mat = new THREE.MeshBasicMaterial({
      color,
      transparent: true,
      opacity: 0.6,
      side: THREE.DoubleSide,
    });
    const ring = new THREE.Mesh(geo, mat);
    ring.position.copy(position);
    ring.position.y = 0.05;
    ring.rotation.x = -Math.PI / 2;
    return ring;
  }

  static createLaserBeam(from, to, color = 0xffdd00) {
    const direction = new THREE.Vector3().subVectors(to, from);
    const length = direction.length();
    const geo = new THREE.CylinderGeometry(0.03, 0.03, length, 6);
    geo.rotateX(Math.PI / 2);
    geo.translate(0, 0, length / 2);
    const mat = new THREE.MeshBasicMaterial({
      color,
      transparent: true,
      opacity: 0.7,
    });
    const beam = new THREE.Mesh(geo, mat);
    beam.position.copy(from);
    beam.lookAt(to);
    return beam;
  }
}
