import './styles.css';

import * as THREE from 'three';
import { Game } from './game/Game.js';

const scene = new THREE.Scene();
scene.background = new THREE.Color('#87CEEB');
scene.fog = new THREE.Fog('#87CEEB', 20, 35);

const camera = new THREE.PerspectiveCamera(
  50,
  window.innerWidth / window.innerHeight,
  0.1,
  100
);
camera.position.set(0, 12, 10);
camera.lookAt(0, 0, 0);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.2;
document.getElementById('app').appendChild(renderer.domElement);

const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
scene.add(ambientLight);

const sunLight = new THREE.DirectionalLight(0xfff4e0, 1.2);
sunLight.position.set(8, 12, 6);
sunLight.castShadow = true;
sunLight.shadow.mapSize.set(2048, 2048);
sunLight.shadow.camera.left = -12;
sunLight.shadow.camera.right = 12;
sunLight.shadow.camera.top = 12;
sunLight.shadow.camera.bottom = -12;
sunLight.shadow.camera.near = 0.5;
sunLight.shadow.camera.far = 40;
sunLight.shadow.bias = -0.001;
scene.add(sunLight);

const hemisphereLight = new THREE.HemisphereLight(0x87CEEB, 0x556b2f, 0.4);
scene.add(hemisphereLight);

const groundGeo = new THREE.PlaneGeometry(40, 30);
const groundMat = new THREE.MeshStandardMaterial({
  color: 0x5a9e4b,
  roughness: 0.9,
  metalness: 0.0,
});
const ground = new THREE.Mesh(groundGeo, groundMat);
ground.rotation.x = -Math.PI / 2;
ground.position.y = -0.01;
ground.receiveShadow = true;
scene.add(ground);

for (let i = 0; i < 6; i++) {
  const cloudGeo = new THREE.SphereGeometry(0.8 + Math.random() * 0.5, 8, 6);
  const cloudMat = new THREE.MeshStandardMaterial({
    color: 0xffffff,
    roughness: 1,
    transparent: true,
    opacity: 0.85,
  });
  const cloud = new THREE.Mesh(cloudGeo, cloudMat);
  cloud.position.set(
    (Math.random() - 0.5) * 20,
    8 + Math.random() * 3,
    (Math.random() - 0.5) * 15
  );
  cloud.scale.set(1.5, 0.5, 1);
  scene.add(cloud);
}

const game = new Game(scene, camera, renderer);

let isDragging = false;
let prevMouse = { x: 0, y: 0 };

renderer.domElement.addEventListener('mousedown', (e) => {
  if (e.button === 1 || e.button === 2) {
    isDragging = true;
    prevMouse = { x: e.clientX, y: e.clientY };
  }
});

window.addEventListener('mouseup', () => {
  isDragging = false;
});

window.addEventListener('mousemove', (e) => {
  if (!isDragging) return;
  const dx = e.clientX - prevMouse.x;
  const dy = e.clientY - prevMouse.y;
  camera.position.x -= dx * 0.02;
  camera.position.z -= dy * 0.02;
  camera.lookAt(camera.position.x, 0, camera.position.z - 10);
  prevMouse = { x: e.clientX, y: e.clientY };
});

renderer.domElement.addEventListener('wheel', (e) => {
  e.preventDefault();
  camera.position.y += e.deltaY * 0.005;
  camera.position.y = Math.max(5, Math.min(20, camera.position.y));
  camera.lookAt(camera.position.x, 0, camera.position.z - 10);
}, { passive: false });

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

let lastTime = performance.now();
function animate(now = performance.now()) {
  const delta = Math.min((now - lastTime) / 1000, 0.05);
  lastTime = now;

  game.update(delta);
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

animate();
