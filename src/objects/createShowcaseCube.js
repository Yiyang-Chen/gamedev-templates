import { BoxGeometry, Mesh, MeshStandardMaterial } from 'three';

export function createShowcaseCube() {
  const geometry = new BoxGeometry();
  const material = new MeshStandardMaterial({
    color: '#d1d5db',
    roughness: 0.35,
    metalness: 0.05,
  });
  const mesh = new Mesh(geometry, material);
  mesh.castShadow = true;

  const update = (delta = 0) => {
    const yawSpeed = 0.6; // radians per second
    const pitchSpeed = 0.3;

    mesh.rotation.y += delta * yawSpeed;
    mesh.rotation.x += delta * pitchSpeed;
  };

  return { mesh, update };
}
