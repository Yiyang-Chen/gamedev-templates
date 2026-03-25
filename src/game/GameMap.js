import * as THREE from 'three';
import { TILE_SIZE, GRID_COLS, GRID_ROWS, TILE_TYPES, MAP_LAYOUT, PATH_WAYPOINTS } from './GameConfig.js';

export class GameMap {
  constructor(scene) {
    this.scene = scene;
    this.group = new THREE.Group();
    this.tileGrid = [];
    this.tileObjects = [];
    this.buildableIndicators = [];

    this.offsetX = -(GRID_COLS * TILE_SIZE) / 2 + TILE_SIZE / 2;
    this.offsetZ = -(GRID_ROWS * TILE_SIZE) / 2 + TILE_SIZE / 2;

    this._buildMap();
    this._buildPath();
    this._buildBorder();
    scene.add(this.group);
  }

  _buildMap() {
    for (let row = 0; row < GRID_ROWS; row++) {
      this.tileGrid[row] = [];
      for (let col = 0; col < GRID_COLS; col++) {
        const type = MAP_LAYOUT[row][col];
        this.tileGrid[row][col] = { type, tower: null };
        this._createTile(col, row, type);
      }
    }
  }

  _createTile(col, row, type) {
    const x = col * TILE_SIZE + this.offsetX;
    const z = row * TILE_SIZE + this.offsetZ;

    let color, height;
    switch (type) {
      case TILE_TYPES.PATH:
        color = 0xc4a35a;
        height = 0.05;
        break;
      case TILE_TYPES.BUILDABLE:
        color = 0x5a9e4b;
        height = 0.12;
        break;
      case TILE_TYPES.BLOCKED:
        color = 0x3a6e30;
        height = 0.2;
        break;
      default:
        color = 0x6abf5e;
        height = 0.1;
        break;
    }

    const geo = new THREE.BoxGeometry(TILE_SIZE * 0.95, height, TILE_SIZE * 0.95);
    const mat = new THREE.MeshStandardMaterial({
      color,
      roughness: 0.8,
      metalness: 0.05,
    });
    const tile = new THREE.Mesh(geo, mat);
    tile.position.set(x, height / 2, z);
    tile.receiveShadow = true;
    tile.userData = { col, row, type };
    this.group.add(tile);
    this.tileObjects.push(tile);

    if (type === TILE_TYPES.BUILDABLE) {
      const indicatorGeo = new THREE.PlaneGeometry(TILE_SIZE * 0.4, TILE_SIZE * 0.4);
      const indicatorMat = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.15,
        side: THREE.DoubleSide,
      });
      const indicator = new THREE.Mesh(indicatorGeo, indicatorMat);
      indicator.position.set(x, height + 0.01, z);
      indicator.rotation.x = -Math.PI / 2;
      indicator.userData = { col, row };
      this.group.add(indicator);
      this.buildableIndicators.push(indicator);
    }
  }

  _buildPath() {
    const waypoints = this.getWorldWaypoints();
    for (let i = 0; i < waypoints.length - 1; i++) {
      const from = waypoints[i];
      const to = waypoints[i + 1];
      const dir = new THREE.Vector3().subVectors(to, from);
      const dist = dir.length();
      const steps = Math.ceil(dist / (TILE_SIZE * 0.5));

      for (let s = 0; s <= steps; s++) {
        const t = s / steps;
        const pos = new THREE.Vector3().lerpVectors(from, to, t);

        if (Math.random() > 0.7) {
          const flowerGeo = new THREE.SphereGeometry(0.04, 6, 4);
          const colors = [0xff88aa, 0xffdd44, 0xaaddff, 0xffaaff];
          const flowerMat = new THREE.MeshStandardMaterial({
            color: colors[Math.floor(Math.random() * colors.length)],
          });
          const flower = new THREE.Mesh(flowerGeo, flowerMat);
          flower.position.set(
            pos.x + (Math.random() - 0.5) * 0.6,
            0.08,
            pos.z + (Math.random() - 0.5) * 0.6
          );
          this.group.add(flower);
        }
      }
    }
  }

  _buildBorder() {
    for (let row = 0; row < GRID_ROWS; row++) {
      for (let col = 0; col < GRID_COLS; col++) {
        if (MAP_LAYOUT[row][col] === TILE_TYPES.BLOCKED) {
          const x = col * TILE_SIZE + this.offsetX;
          const z = row * TILE_SIZE + this.offsetZ;

          if (Math.random() > 0.6) {
            const treeGroup = new THREE.Group();
            const trunkGeo = new THREE.CylinderGeometry(0.04, 0.06, 0.3, 6);
            const trunkMat = new THREE.MeshStandardMaterial({ color: 0x8B6914 });
            const trunk = new THREE.Mesh(trunkGeo, trunkMat);
            trunk.position.y = 0.35;
            trunk.castShadow = true;
            treeGroup.add(trunk);

            const leavesGeo = new THREE.SphereGeometry(0.18, 8, 6);
            const leavesMat = new THREE.MeshStandardMaterial({
              color: 0x2d8b46,
              roughness: 0.8,
            });
            const leaves = new THREE.Mesh(leavesGeo, leavesMat);
            leaves.position.y = 0.55;
            leaves.castShadow = true;
            treeGroup.add(leaves);

            treeGroup.position.set(x + (Math.random() - 0.5) * 0.3, 0, z + (Math.random() - 0.5) * 0.3);
            treeGroup.scale.setScalar(0.8 + Math.random() * 0.6);
            this.group.add(treeGroup);
          }
        }
      }
    }
  }

  getWorldPos(col, row) {
    return new THREE.Vector3(
      col * TILE_SIZE + this.offsetX,
      0,
      row * TILE_SIZE + this.offsetZ
    );
  }

  getWorldWaypoints() {
    return PATH_WAYPOINTS.map(wp => this.getWorldPos(wp.col, wp.row));
  }

  getTileAt(col, row) {
    if (row >= 0 && row < GRID_ROWS && col >= 0 && col < GRID_COLS) {
      return this.tileGrid[row][col];
    }
    return null;
  }

  canBuild(col, row) {
    const tile = this.getTileAt(col, row);
    return tile && tile.type === TILE_TYPES.BUILDABLE && !tile.tower;
  }

  canBuildOnPath(col, row) {
    const tile = this.getTileAt(col, row);
    return tile && tile.type === TILE_TYPES.PATH && !tile.tower;
  }

  placeTower(col, row, tower) {
    const tile = this.getTileAt(col, row);
    if (tile) {
      tile.tower = tower;
    }
  }

  removeTower(col, row) {
    const tile = this.getTileAt(col, row);
    if (tile) {
      tile.tower = null;
    }
  }

  worldToGrid(worldPos) {
    const col = Math.round((worldPos.x - this.offsetX) / TILE_SIZE);
    const row = Math.round((worldPos.z - this.offsetZ) / TILE_SIZE);
    return { col, row };
  }

  getTileObjects() {
    return this.tileObjects.filter(t =>
      t.userData.type === TILE_TYPES.BUILDABLE || t.userData.type === TILE_TYPES.PATH
    );
  }

  dispose() {
    this.scene.remove(this.group);
  }
}
