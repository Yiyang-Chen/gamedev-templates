import { AmbientLight, DirectionalLight } from 'three';

export function createLights() {
  const ambient = new AmbientLight(0xffffff, 0.35);

  const main = new DirectionalLight(0xffffff, 1);
  main.position.set(5, 5, 5);
  main.castShadow = true;
  main.shadow.mapSize.set(2048, 2048);
  main.shadow.camera.left = -10;
  main.shadow.camera.right = 10;
  main.shadow.camera.top = 10;
  main.shadow.camera.bottom = -10;
  main.shadow.camera.near = 0.5;
  main.shadow.camera.far = 50;

  return { ambient, main, directional: main };
}
