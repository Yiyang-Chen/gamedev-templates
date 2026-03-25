import * as THREE from 'three';

const _v = new THREE.Vector3();

function makeMat(color, opts = {}) {
  return new THREE.MeshStandardMaterial({
    color,
    roughness: opts.roughness ?? 0.55,
    metalness: opts.metalness ?? 0.05,
    flatShading: true,
    ...opts,
  });
}

function addFace(mesh, color) {
  const eyeGeo = new THREE.SphereGeometry(0.04, 6, 4);
  const eyeMat = makeMat(0x111111);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.08, 0.15, 0.2);
  mesh.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.08;
  mesh.add(eyeR);

  const pupilGeo = new THREE.SphereGeometry(0.02, 4, 3);
  const pupilMat = makeMat(0xffffff);
  const pupilL = new THREE.Mesh(pupilGeo, pupilMat);
  pupilL.position.set(-0.08, 0.17, 0.23);
  mesh.add(pupilL);
  const pupilR = pupilL.clone();
  pupilR.position.x = 0.08;
  mesh.add(pupilR);

  const mouthGeo = new THREE.TorusGeometry(0.04, 0.012, 4, 6, Math.PI);
  const mouthMat = makeMat(0x222222);
  const mouth = new THREE.Mesh(mouthGeo, mouthMat);
  mouth.position.set(0, 0.06, 0.22);
  mouth.rotation.x = Math.PI;
  mesh.add(mouth);
}

export function createStrawberryModel(level = 0) {
  const group = new THREE.Group();
  const s = 1 + level * 0.1;
  const bodyGeo = new THREE.SphereGeometry(0.25 * s, 8, 6);
  bodyGeo.scale(1, 1.3, 1);
  const bodyMat = makeMat(0xff2244);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.32 * s;
  group.add(body);

  const seedGeo = new THREE.SphereGeometry(0.02, 4, 3);
  const seedMat = makeMat(0xffee88);
  for (let i = 0; i < 8; i++) {
    const seed = new THREE.Mesh(seedGeo, seedMat);
    const a = (i / 8) * Math.PI * 2;
    seed.position.set(
      Math.sin(a) * 0.2 * s,
      0.28 * s + Math.cos(a * 2) * 0.08,
      Math.cos(a) * 0.2 * s
    );
    group.add(seed);
  }

  const leafGeo = new THREE.ConeGeometry(0.15 * s, 0.1, 5);
  const leafMat = makeMat(0x44cc44);
  const leaf = new THREE.Mesh(leafGeo, leafMat);
  leaf.position.y = 0.6 * s;
  group.add(leaf);

  addFace(body, 0xff2244);

  if (level >= 2) {
    const crownGeo = new THREE.ConeGeometry(0.06, 0.12, 5);
    const crownMat = makeMat(0xffdd44);
    const crown = new THREE.Mesh(crownGeo, crownMat);
    crown.position.y = 0.7 * s;
    group.add(crown);
  }

  return group;
}

export function createWatermelonModel(level = 0) {
  const group = new THREE.Group();
  const s = 1 + level * 0.1;
  const bodyGeo = new THREE.SphereGeometry(0.3 * s, 10, 7);
  bodyGeo.scale(1.2, 1, 1);
  const bodyMat = makeMat(0x33aa33);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.3 * s;
  group.add(body);

  const stripeGeo = new THREE.TorusGeometry(0.28 * s, 0.02, 4, 12);
  const stripeMat = makeMat(0x226622);
  for (let i = 0; i < 4; i++) {
    const stripe = new THREE.Mesh(stripeGeo, stripeMat);
    stripe.rotation.y = (i / 4) * Math.PI;
    stripe.position.y = 0.3 * s;
    group.add(stripe);
  }

  addFace(body, 0x33aa33);

  if (level >= 2) {
    const swordGeo = new THREE.BoxGeometry(0.04, 0.25, 0.02);
    const swordMat = makeMat(0xaaaacc, { metalness: 0.6 });
    const sword = new THREE.Mesh(swordGeo, swordMat);
    sword.position.set(0.3, 0.4, 0);
    sword.rotation.z = -0.3;
    group.add(sword);
  }

  return group;
}

export function createLemonModel(level = 0) {
  const group = new THREE.Group();
  const s = 1 + level * 0.1;
  const bodyGeo = new THREE.SphereGeometry(0.22 * s, 8, 6);
  bodyGeo.scale(1, 1.4, 1);
  const bodyMat = makeMat(0xffee33);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.3 * s;
  group.add(body);

  const tipGeo = new THREE.ConeGeometry(0.06 * s, 0.12, 5);
  const tipMat = makeMat(0xccaa00);
  const tipTop = new THREE.Mesh(tipGeo, tipMat);
  tipTop.position.y = 0.58 * s;
  group.add(tipTop);
  const tipBot = new THREE.Mesh(tipGeo, tipMat);
  tipBot.position.y = 0.02;
  tipBot.rotation.x = Math.PI;
  group.add(tipBot);

  addFace(body, 0xffee33);

  if (level >= 2) {
    const auraGeo = new THREE.RingGeometry(0.28 * s, 0.32 * s, 12);
    const auraMat = makeMat(0xffff88, { transparent: true, opacity: 0.4, side: THREE.DoubleSide });
    const aura = new THREE.Mesh(auraGeo, auraMat);
    aura.position.y = 0.3 * s;
    aura.rotation.x = Math.PI / 2;
    group.add(aura);
  }

  return group;
}

export function createCherryModel(level = 0) {
  const group = new THREE.Group();
  const s = 1 + level * 0.1;

  const cherryGeo = new THREE.SphereGeometry(0.15 * s, 7, 5);
  const cherryMat = makeMat(0xcc0044);

  const cherry1 = new THREE.Mesh(cherryGeo, cherryMat);
  cherry1.position.set(-0.1, 0.18 * s, 0);
  group.add(cherry1);

  const cherry2 = new THREE.Mesh(cherryGeo, cherryMat);
  cherry2.position.set(0.1, 0.22 * s, 0);
  group.add(cherry2);

  addFace(cherry1, 0xcc0044);

  const stemCurve = new THREE.QuadraticBezierCurve3(
    new THREE.Vector3(-0.1, 0.32 * s, 0),
    new THREE.Vector3(0, 0.55 * s, 0),
    new THREE.Vector3(0.1, 0.36 * s, 0)
  );
  const stemGeo = new THREE.TubeGeometry(stemCurve, 8, 0.015, 4, false);
  const stemMat = makeMat(0x44aa22);
  const stem = new THREE.Mesh(stemGeo, stemMat);
  group.add(stem);

  if (level >= 2) {
    const glowGeo = new THREE.SphereGeometry(0.06, 5, 4);
    const glowMat = makeMat(0xff6688, { emissive: 0xff3355, emissiveIntensity: 0.5 });
    const glow1 = new THREE.Mesh(glowGeo, glowMat);
    glow1.position.copy(cherry1.position);
    glow1.position.y += 0.15;
    group.add(glow1);
  }

  return group;
}

export function createPineappleModel(level = 0) {
  const group = new THREE.Group();
  const s = 1 + level * 0.1;

  const bodyGeo = new THREE.CylinderGeometry(0.2 * s, 0.22 * s, 0.45 * s, 8);
  const bodyMat = makeMat(0xddaa00);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.25 * s;
  group.add(body);

  const patternGeo = new THREE.BoxGeometry(0.03, 0.03, 0.03);
  const patternMat = makeMat(0xbb8800);
  for (let ring = 0; ring < 3; ring++) {
    for (let i = 0; i < 6; i++) {
      const p = new THREE.Mesh(patternGeo, patternMat);
      const a = ((i + ring * 0.5) / 6) * Math.PI * 2;
      const ry = 0.12 + ring * 0.12;
      p.position.set(
        Math.sin(a) * 0.21 * s,
        ry * s,
        Math.cos(a) * 0.21 * s
      );
      group.add(p);
    }
  }

  const leafMat = makeMat(0x44aa22);
  for (let i = 0; i < 5; i++) {
    const leafGeo = new THREE.ConeGeometry(0.04 * s, 0.2, 4);
    const leaf = new THREE.Mesh(leafGeo, leafMat);
    const a = (i / 5) * Math.PI * 2;
    leaf.position.set(
      Math.sin(a) * 0.06,
      0.55 * s,
      Math.cos(a) * 0.06
    );
    leaf.rotation.x = Math.sin(a) * 0.3;
    leaf.rotation.z = Math.cos(a) * 0.3;
    group.add(leaf);
  }

  addFace(body, 0xddaa00);

  if (level >= 2) {
    const spikeGeo = new THREE.ConeGeometry(0.03, 0.1, 4);
    const spikeMat = makeMat(0xff6600, { metalness: 0.3 });
    for (let i = 0; i < 6; i++) {
      const spike = new THREE.Mesh(spikeGeo, spikeMat);
      const a = (i / 6) * Math.PI * 2;
      spike.position.set(
        Math.sin(a) * 0.26 * s,
        0.25 * s,
        Math.cos(a) * 0.26 * s
      );
      spike.rotation.z = -Math.sin(a) * 1.2;
      spike.rotation.x = Math.cos(a) * 1.2;
      group.add(spike);
    }
  }

  return group;
}

export function createCaterpillarModel() {
  const group = new THREE.Group();
  const bodyMat = makeMat(0x66cc33);
  const segGeo = new THREE.SphereGeometry(0.12, 6, 5);

  for (let i = 0; i < 4; i++) {
    const seg = new THREE.Mesh(segGeo, bodyMat);
    seg.position.set(0, 0.12, -i * 0.18);
    seg.scale.y = 0.9;
    group.add(seg);
  }

  const headGeo = new THREE.SphereGeometry(0.14, 7, 5);
  const head = new THREE.Mesh(headGeo, bodyMat);
  head.position.set(0, 0.14, 0.15);
  group.add(head);

  const eyeGeo = new THREE.SphereGeometry(0.03, 4, 3);
  const eyeMat = makeMat(0x111111);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.06, 0.2, 0.26);
  group.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.06;
  group.add(eyeR);

  const antennaGeo = new THREE.CylinderGeometry(0.008, 0.008, 0.1, 3);
  const antennaMat = makeMat(0x449922);
  const antL = new THREE.Mesh(antennaGeo, antennaMat);
  antL.position.set(-0.05, 0.28, 0.15);
  antL.rotation.z = 0.4;
  group.add(antL);
  const antR = antL.clone();
  antR.position.x = 0.05;
  antR.rotation.z = -0.4;
  group.add(antR);

  return group;
}

export function createAntModel() {
  const group = new THREE.Group();
  const mat = makeMat(0x443322);

  const headGeo = new THREE.SphereGeometry(0.1, 6, 5);
  const head = new THREE.Mesh(headGeo, mat);
  head.position.set(0, 0.1, 0.15);
  group.add(head);

  const thoraxGeo = new THREE.SphereGeometry(0.08, 6, 5);
  const thorax = new THREE.Mesh(thoraxGeo, mat);
  thorax.position.set(0, 0.1, 0);
  group.add(thorax);

  const abdGeo = new THREE.SphereGeometry(0.12, 6, 5);
  const abd = new THREE.Mesh(abdGeo, mat);
  abd.position.set(0, 0.1, -0.2);
  group.add(abd);

  const eyeGeo = new THREE.SphereGeometry(0.025, 4, 3);
  const eyeMat = makeMat(0xffffff);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.05, 0.14, 0.23);
  group.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.05;
  group.add(eyeR);

  const legGeo = new THREE.CylinderGeometry(0.006, 0.006, 0.12, 3);
  const legMat = makeMat(0x332211);
  for (let i = 0; i < 3; i++) {
    const legL = new THREE.Mesh(legGeo, legMat);
    legL.position.set(-0.1, 0.04, -0.05 + i * 0.08);
    legL.rotation.z = 0.8;
    group.add(legL);
    const legR = legL.clone();
    legR.position.x = 0.1;
    legR.rotation.z = -0.8;
    group.add(legR);
  }

  return group;
}

export function createBeetleModel() {
  const group = new THREE.Group();
  const shellMat = makeMat(0x335577, { metalness: 0.3, roughness: 0.4 });

  const shellGeo = new THREE.SphereGeometry(0.18, 8, 6);
  shellGeo.scale(1.2, 0.8, 1.3);
  const shell = new THREE.Mesh(shellGeo, shellMat);
  shell.position.y = 0.14;
  group.add(shell);

  const headGeo = new THREE.SphereGeometry(0.1, 6, 5);
  const headMat = makeMat(0x224466);
  const head = new THREE.Mesh(headGeo, headMat);
  head.position.set(0, 0.12, 0.22);
  group.add(head);

  const eyeGeo = new THREE.SphereGeometry(0.03, 4, 3);
  const eyeMat = makeMat(0xeeeeff);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.06, 0.16, 0.3);
  group.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.06;
  group.add(eyeR);

  const hornGeo = new THREE.ConeGeometry(0.02, 0.12, 4);
  const hornMat = makeMat(0x112233);
  const horn = new THREE.Mesh(hornGeo, hornMat);
  horn.position.set(0, 0.22, 0.25);
  horn.rotation.x = -0.6;
  group.add(horn);

  return group;
}

export function createLadybugModel() {
  const group = new THREE.Group();
  const bodyMat = makeMat(0xdd3333);

  const bodyGeo = new THREE.SphereGeometry(0.15, 8, 6);
  bodyGeo.scale(1.1, 0.7, 1.2);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.1;
  group.add(body);

  const dotGeo = new THREE.SphereGeometry(0.025, 5, 4);
  const dotMat = makeMat(0x111111);
  const dots = [
    [-0.06, 0.15, -0.05],
    [0.06, 0.15, -0.05],
    [-0.08, 0.13, 0.05],
    [0.08, 0.13, 0.05],
    [0, 0.16, -0.1],
  ];
  for (const [x, y, z] of dots) {
    const dot = new THREE.Mesh(dotGeo, dotMat);
    dot.position.set(x, y, z);
    group.add(dot);
  }

  const headGeo = new THREE.SphereGeometry(0.08, 6, 5);
  const headMat = makeMat(0x111111);
  const head = new THREE.Mesh(headGeo, headMat);
  head.position.set(0, 0.1, 0.18);
  group.add(head);

  const eyeGeo = new THREE.SphereGeometry(0.02, 4, 3);
  const eyeMat = makeMat(0xffffff);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.04, 0.14, 0.24);
  group.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.04;
  group.add(eyeR);

  return group;
}

export function createWaspModel() {
  const group = new THREE.Group();

  const bodyGeo = new THREE.SphereGeometry(0.22, 8, 6);
  bodyGeo.scale(1, 0.8, 1.5);
  const bodyMat = makeMat(0xffcc00);
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  body.position.y = 0.2;
  group.add(body);

  const stripeGeo = new THREE.TorusGeometry(0.2, 0.025, 4, 12);
  const stripeMat = makeMat(0x222222);
  for (let i = -1; i <= 1; i++) {
    const stripe = new THREE.Mesh(stripeGeo, stripeMat);
    stripe.position.set(0, 0.2, i * 0.1);
    stripe.rotation.y = Math.PI / 2;
    group.add(stripe);
  }

  const headGeo = new THREE.SphereGeometry(0.12, 7, 5);
  const headMat = makeMat(0xffcc00);
  const head = new THREE.Mesh(headGeo, headMat);
  head.position.set(0, 0.22, 0.32);
  group.add(head);

  const eyeGeo = new THREE.SphereGeometry(0.04, 5, 4);
  const eyeMat = makeMat(0xff0000);
  const eyeL = new THREE.Mesh(eyeGeo, eyeMat);
  eyeL.position.set(-0.07, 0.26, 0.4);
  group.add(eyeL);
  const eyeR = eyeL.clone();
  eyeR.position.x = 0.07;
  group.add(eyeR);

  const stingerGeo = new THREE.ConeGeometry(0.03, 0.15, 4);
  const stingerMat = makeMat(0x111111);
  const stinger = new THREE.Mesh(stingerGeo, stingerMat);
  stinger.position.set(0, 0.18, -0.38);
  stinger.rotation.x = Math.PI / 2;
  group.add(stinger);

  const wingMat = makeMat(0xffffff, { transparent: true, opacity: 0.35, side: THREE.DoubleSide });
  const wingGeo = new THREE.PlaneGeometry(0.25, 0.12);
  const wingL = new THREE.Mesh(wingGeo, wingMat);
  wingL.position.set(-0.18, 0.35, 0);
  wingL.rotation.set(0, 0, 0.3);
  group.add(wingL);
  const wingR = new THREE.Mesh(wingGeo, wingMat);
  wingR.position.set(0.18, 0.35, 0);
  wingR.rotation.set(0, 0, -0.3);
  group.add(wingR);

  return group;
}

const TOWER_MODEL_MAP = {
  strawberry: createStrawberryModel,
  watermelon: createWatermelonModel,
  lemon: createLemonModel,
  cherry: createCherryModel,
  pineapple: createPineappleModel,
};

const ENEMY_MODEL_MAP = {
  caterpillar: createCaterpillarModel,
  ant: createAntModel,
  beetle: createBeetleModel,
  ladybug: createLadybugModel,
  wasp: createWaspModel,
};

export function createTowerModel(type, level = 0) {
  const fn = TOWER_MODEL_MAP[type];
  if (!fn) return new THREE.Group();
  const m = fn(level);
  m.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true;
      child.receiveShadow = true;
    }
  });
  return m;
}

export function createEnemyModel(type) {
  const fn = ENEMY_MODEL_MAP[type];
  if (!fn) return new THREE.Group();
  const m = fn();
  m.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true;
      child.receiveShadow = true;
    }
  });
  return m;
}
