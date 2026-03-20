import { Color, Scene } from 'three';

export function createScene() {
  const scene = new Scene();
  scene.background = new Color('#1e1e1e');
  return scene;
}
