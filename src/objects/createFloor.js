import { Mesh, MeshStandardMaterial, PlaneGeometry } from 'three';

export function createFloor() {
  const geometry = new PlaneGeometry(6, 6);
  const material = new MeshStandardMaterial({
    color: '#232323',
    roughness: 0.8,
    metalness: 0,
  });

  const mesh = new Mesh(geometry, material);
  mesh.rotation.x = -Math.PI / 2;
  mesh.position.y = -0.5;
  mesh.receiveShadow = true;

  return mesh;
}
