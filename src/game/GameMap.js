import * as THREE from 'three';
import {
  MAP_LAYOUT, MAP_COLS, MAP_ROWS, GRID_SIZE,
  CELL_PATH, CELL_BUILDABLE, CELL_BLOCKED, CELL_START, CELL_END,
  PATH_WAYPOINTS,
} from './GameConfig.js';

export class GameMap {
  constructor(scene) {
    this.scene = scene;
    this.grid = MAP_LAYOUT.map(row => [...row]);
    this.cols = MAP_COLS;
    this.rows = MAP_ROWS;
    this.group = new THREE.Group();
    this.group.name = 'GameMap';
    scene.add(this.group);

    this.pathPoints = [];
    this._buildVisuals();
    this._buildPathPoints();
  }

  _cellCenter(col, row) {
    const x = (col - this.cols / 2 + 0.5) * GRID_SIZE;
    const z = (row - this.rows / 2 + 0.5) * GRID_SIZE;
    return new THREE.Vector3(x, 0, z);
  }

  _buildVisuals() {
    const grassColors = [0x7abb5e, 0x6eaf52, 0x82c766];
    const pathColor = 0xd4c4a0;
    const edgeColor = 0x556644;
    const startColor = 0x55bbff;
    const endColor = 0xff7744;

    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        const cell = this.grid[r][c];
        const pos = this._cellCenter(c, r);

        let color;
        let height = 0.08;
        if (cell === CELL_PATH || cell === CELL_START || cell === CELL_END) {
          color = cell === CELL_START ? startColor : cell === CELL_END ? endColor : pathColor;
          height = 0.04;
        } else if (cell === CELL_BUILDABLE) {
          color = grassColors[(c + r) % grassColors.length];
        } else {
          color = edgeColor;
          height = 0.15;
        }

        const geo = new THREE.BoxGeometry(GRID_SIZE * 0.96, height, GRID_SIZE * 0.96);
        const mat = new THREE.MeshStandardMaterial({
          color,
          roughness: 0.8,
          metalness: 0.05,
          flatShading: true,
        });
        const tile = new THREE.Mesh(geo, mat);
        tile.position.set(pos.x, height / 2 - 0.02, pos.z);
        tile.receiveShadow = true;
        tile.userData = { col: c, row: r, cellType: cell };
        this.group.add(tile);

        if (cell === CELL_BUILDABLE) {
          this._addGrassDecor(pos, c, r);
        }
      }
    }

    const baseGeo = new THREE.BoxGeometry(
      this.cols * GRID_SIZE + 1,
      0.1,
      this.rows * GRID_SIZE + 1
    );
    const baseMat = new THREE.MeshStandardMaterial({
      color: 0x3a5a2a,
      roughness: 0.9,
      flatShading: true,
    });
    const base = new THREE.Mesh(baseGeo, baseMat);
    base.position.y = -0.08;
    base.receiveShadow = true;
    this.group.add(base);

    this._addEndpoint();
  }

  _addGrassDecor(pos, c, r) {
    const rng = Math.sin(c * 13.7 + r * 7.3) * 0.5 + 0.5;
    if (rng < 0.3) {
      const flowerGeo = new THREE.SphereGeometry(0.04, 5, 4);
      const flowerColors = [0xff88aa, 0xffaa44, 0xaaddff, 0xffff77];
      const fMat = new THREE.MeshStandardMaterial({
        color: flowerColors[Math.floor(rng * 40) % flowerColors.length],
        roughness: 0.6,
        flatShading: true,
      });
      const flower = new THREE.Mesh(flowerGeo, fMat);
      flower.position.set(
        pos.x + (rng - 0.5) * 0.3,
        0.08,
        pos.z + (Math.cos(c + r) * 0.15)
      );
      this.group.add(flower);
    }
  }

  _addEndpoint() {
    const endWP = PATH_WAYPOINTS[PATH_WAYPOINTS.length - 1];
    const pos = this._cellCenter(endWP.col, endWP.row);

    const baseGeo = new THREE.CylinderGeometry(0.25, 0.3, 0.15, 8);
    const baseMat = new THREE.MeshStandardMaterial({
      color: 0x88cc44,
      roughness: 0.6,
      flatShading: true,
    });
    const basket = new THREE.Mesh(baseGeo, baseMat);
    basket.position.set(pos.x, 0.1, pos.z);
    basket.castShadow = true;
    this.group.add(basket);

    const fruitGeo = new THREE.SphereGeometry(0.12, 7, 5);
    const fruitMat = new THREE.MeshStandardMaterial({
      color: 0xff6633,
      roughness: 0.5,
      flatShading: true,
    });
    const fruit = new THREE.Mesh(fruitGeo, fruitMat);
    fruit.position.set(pos.x, 0.3, pos.z);
    fruit.castShadow = true;
    this.group.add(fruit);
    this.endpointFruit = fruit;

    const leafGeo = new THREE.ConeGeometry(0.06, 0.1, 4);
    const leafMat = new THREE.MeshStandardMaterial({
      color: 0x44aa22,
      roughness: 0.6,
      flatShading: true,
    });
    const leaf = new THREE.Mesh(leafGeo, leafMat);
    leaf.position.set(pos.x, 0.42, pos.z);
    this.group.add(leaf);
  }

  _buildPathPoints() {
    this.pathPoints = PATH_WAYPOINTS.map(wp => this._cellCenter(wp.col, wp.row));
    this.pathPoints.forEach(p => { p.y = 0.05; });
  }

  getPathPoints() {
    return this.pathPoints;
  }

  canBuild(col, row) {
    if (col < 0 || col >= this.cols || row < 0 || row >= this.rows) return false;
    return this.grid[row][col] === CELL_BUILDABLE;
  }

  setOccupied(col, row) {
    if (this.canBuild(col, row)) {
      this.grid[row][col] = CELL_BLOCKED;
    }
  }

  setFree(col, row) {
    this.grid[row][col] = CELL_BUILDABLE;
  }

  worldToGrid(worldPos) {
    const col = Math.floor(worldPos.x / GRID_SIZE + this.cols / 2);
    const row = Math.floor(worldPos.z / GRID_SIZE + this.rows / 2);
    return { col, row };
  }

  gridToWorld(col, row) {
    return this._cellCenter(col, row);
  }

  update(dt) {
    if (this.endpointFruit) {
      this.endpointFruit.rotation.y += dt * 1.5;
      this.endpointFruit.position.y = 0.3 + Math.sin(Date.now() * 0.003) * 0.05;
    }
  }
}
