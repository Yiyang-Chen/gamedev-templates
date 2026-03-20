import { PCFSoftShadowMap, WebGLRenderer } from 'three';

export function createRenderer({ container = document.getElementById('app') } = {}) {
  const renderer = new WebGLRenderer({ antialias: true });
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = PCFSoftShadowMap;
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

  const mountTarget = container ?? document.body;
  mountTarget.appendChild(renderer.domElement);

  return renderer;
}
