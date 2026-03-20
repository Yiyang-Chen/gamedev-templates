import { debounce } from '../utils/debounce.js';

export function setupResize({ renderer, camera, wait = 100 }) {
  function handleResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  }

  window.addEventListener('resize', debounce(handleResize, wait));
}
