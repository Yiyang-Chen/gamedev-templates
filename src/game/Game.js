import * as THREE from 'three';
import { GameMap } from './GameMap.js';
import { Tower } from './Tower.js';
import { WaveManager } from './WaveManager.js';
import { ParticleSystem } from './ParticleSystem.js';
import { UI } from './UI.js';
import {
  TOWER_TYPES, STARTING_COINS, STARTING_LIVES,
  GRID_SIZE, MAP_COLS, MAP_ROWS,
} from './GameConfig.js';

export class Game {
  constructor({ scene, camera, renderer, container }) {
    this.scene = scene;
    this.camera = camera;
    this.renderer = renderer;
    this.container = container;

    this.coins = STARTING_COINS;
    this.lives = STARTING_LIVES;
    this.towers = [];
    this.projectiles = [];
    this.selectedTower = null;
    this.gameOver = false;
    this.victory = false;
    this.speedMultiplier = 1;
    this.placementPreview = null;

    this._setupScene();
    this._setupCamera();
    this._setupRaycaster();

    this.gameMap = new GameMap(scene);
    this.particleSystem = new ParticleSystem(scene);
    this.waveManager = new WaveManager(scene, this.gameMap.getPathPoints());

    this.waveManager.onEnemyDeath = (enemy) => {
      this.coins += enemy.reward;
      this.ui.updateCoins(this.coins);
      this.particleSystem.emitAt(enemy.mesh.position, 10, 0xffdd44, 0.6);
    };

    this.waveManager.onEnemyReachEnd = (enemy) => {
      this.lives -= enemy.isBoss ? 5 : 1;
      this.ui.updateLives(this.lives);
      this.particleSystem.emitAt(enemy.mesh.position, 8, 0xff3333, 0.5);
      if (this.lives <= 0) {
        this.lives = 0;
        this.gameOver = true;
        this.ui.showGameOver(() => this._restart());
      }
    };

    this.ui = new UI(container);
    this.ui.updateCoins(this.coins);
    this.ui.updateLives(this.lives);
    this.ui.updateWave(0, this.waveManager.totalWaves);
    this.ui.setWaveButtonState(true);

    this.ui.onTowerSelect = (type) => {
      this._deselectPlacedTower();
      this._showPlacementPreview(type);
    };

    this.ui.onStartWave = () => {
      if (!this.waveManager.isWaveComplete()) return;
      const started = this.waveManager.startNextWave();
      if (started) {
        this.ui.updateWave(this.waveManager.currentWave + 1, this.waveManager.totalWaves);
        this.ui.setWaveButtonState(false);
      }
    };

    this.ui.onUpgrade = () => {
      this._upgradeTower();
    };

    this.ui.onSell = () => {
      this._sellTower();
    };

    this.ui.onSpeedToggle = () => {
      this.speedMultiplier = this.speedMultiplier === 1 ? 2 : this.speedMultiplier === 2 ? 3 : 1;
      this.ui.updateSpeed(this.speedMultiplier);
    };

    this._bindEvents();
  }

  _setupScene() {
    this.scene.background = new THREE.Color(0x88ccff);
    this.scene.fog = new THREE.Fog(0x88ccff, 15, 30);

    const existing = this.scene.children.filter(c =>
      c.isLight || c.name === 'ShowcaseCube' || c.name === 'Floor'
    );
    existing.forEach(c => this.scene.remove(c));

    const ambient = new THREE.AmbientLight(0xffffff, 0.6);
    this.scene.add(ambient);

    const sun = new THREE.DirectionalLight(0xfff5e0, 1.2);
    sun.position.set(8, 12, 6);
    sun.castShadow = true;
    sun.shadow.mapSize.set(2048, 2048);
    sun.shadow.camera.left = -12;
    sun.shadow.camera.right = 12;
    sun.shadow.camera.top = 12;
    sun.shadow.camera.bottom = -12;
    sun.shadow.camera.near = 0.1;
    sun.shadow.camera.far = 30;
    sun.shadow.bias = -0.001;
    this.scene.add(sun);

    const fill = new THREE.DirectionalLight(0x88aaff, 0.3);
    fill.position.set(-5, 5, -5);
    this.scene.add(fill);
  }

  _setupCamera() {
    this.camera.position.set(0, 12, 10);
    this.camera.lookAt(0, 0, 0);
    this.camera.fov = 50;
    this.camera.updateProjectionMatrix();
  }

  _setupRaycaster() {
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();
    this.groundPlane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
    this.intersectPoint = new THREE.Vector3();
  }

  _bindEvents() {
    this._onMouseMove = (e) => this._handleMouseMove(e);
    this._onClick = (e) => this._handleClick(e);
    this._onKeyDown = (e) => this._handleKeyDown(e);

    this.renderer.domElement.addEventListener('mousemove', this._onMouseMove);
    this.renderer.domElement.addEventListener('click', this._onClick);
    window.addEventListener('keydown', this._onKeyDown);
  }

  _handleMouseMove(e) {
    const rect = this.renderer.domElement.getBoundingClientRect();
    this.mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
    this.mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;

    if (this.ui.selectedTowerType && this.placementPreview) {
      this.raycaster.setFromCamera(this.mouse, this.camera);
      if (this.raycaster.ray.intersectPlane(this.groundPlane, this.intersectPoint)) {
        const { col, row } = this.gameMap.worldToGrid(this.intersectPoint);
        const canBuild = this.gameMap.canBuild(col, row);
        const pos = this.gameMap.gridToWorld(col, row);
        this.placementPreview.position.set(pos.x, 0.05, pos.z);
        this.placementPreview.visible = true;
        this.placementPreview.traverse(child => {
          if (child.isMesh && child.material) {
            if (child === this.previewBase) {
              child.material.color.setHex(canBuild ? 0x44ff44 : 0xff4444);
            }
          }
        });
      }
    }
  }

  _handleClick(e) {
    if (this.gameOver || this.victory) return;

    if (e.target.closest('#game-ui')) return;

    this.raycaster.setFromCamera(this.mouse, this.camera);

    if (this.ui.selectedTowerType) {
      if (this.raycaster.ray.intersectPlane(this.groundPlane, this.intersectPoint)) {
        const { col, row } = this.gameMap.worldToGrid(this.intersectPoint);
        this._tryPlaceTower(this.ui.selectedTowerType, col, row);
      }
      return;
    }

    const towerMeshes = this.towers.map(t => t.mesh);
    const intersects = this.raycaster.intersectObjects(towerMeshes, true);
    if (intersects.length > 0) {
      let obj = intersects[0].object;
      while (obj.parent && !obj.name.startsWith('Tower_')) {
        obj = obj.parent;
      }
      const tower = this.towers.find(t => t.mesh === obj);
      if (tower) {
        this._selectPlacedTower(tower);
        return;
      }
    }

    this._deselectPlacedTower();
    this.ui.hideInfoPanel();
  }

  _handleKeyDown(e) {
    if (e.key === 'Escape') {
      this.ui.deselectTower();
      this._deselectPlacedTower();
      this._removePlacementPreview();
      this.ui.hideInfoPanel();
    }
  }

  _showPlacementPreview(type) {
    this._removePlacementPreview();

    this.placementPreview = new THREE.Group();
    const baseGeo = new THREE.CylinderGeometry(0.4, 0.4, 0.05, 16);
    const baseMat = new THREE.MeshBasicMaterial({
      color: 0x44ff44,
      transparent: true,
      opacity: 0.5,
    });
    this.previewBase = new THREE.Mesh(baseGeo, baseMat);
    this.placementPreview.add(this.previewBase);
    this.placementPreview.visible = false;
    this.scene.add(this.placementPreview);
  }

  _removePlacementPreview() {
    if (this.placementPreview) {
      this.scene.remove(this.placementPreview);
      this.placementPreview = null;
      this.previewBase = null;
    }
  }

  _tryPlaceTower(type, col, row) {
    if (!this.gameMap.canBuild(col, row)) return;

    const config = TOWER_TYPES[type];
    if (this.coins < config.cost) return;

    const existing = this.towers.find(t => t.col === col && t.row === row);
    if (existing) return;

    this.coins -= config.cost;
    this.ui.updateCoins(this.coins);

    const tower = new Tower(type, col, row, (c, r) => this.gameMap.gridToWorld(c, r), this.scene);
    this.towers.push(tower);
    this.gameMap.setOccupied(col, row);

    this.particleSystem.emitAt(tower.position, 8, config.color, 0.4);
  }

  _selectPlacedTower(tower) {
    this._deselectPlacedTower();
    this.ui.deselectTower();
    this._removePlacementPreview();

    this.selectedTower = tower;
    tower.showRange(true);
    this.ui.showInfoPanel(tower);
  }

  _deselectPlacedTower() {
    if (this.selectedTower) {
      this.selectedTower.showRange(false);
      this.selectedTower = null;
    }
  }

  _upgradeTower() {
    if (!this.selectedTower) return;
    if (!this.selectedTower.canUpgrade()) return;

    const cost = this.selectedTower.getUpgradeCost();
    if (this.coins < cost) return;

    this.coins -= cost;
    this.selectedTower.upgrade();
    this.ui.updateCoins(this.coins);
    this.ui.showInfoPanel(this.selectedTower);
    this.particleSystem.emitAt(this.selectedTower.position, 10, 0xffff44, 0.5);
  }

  _sellTower() {
    if (!this.selectedTower) return;

    const value = this.selectedTower.getSellValue();
    this.coins += value;
    this.ui.updateCoins(this.coins);

    this.gameMap.setFree(this.selectedTower.col, this.selectedTower.row);
    this.selectedTower.dispose();
    this.towers = this.towers.filter(t => t !== this.selectedTower);
    this.selectedTower = null;
    this.ui.hideInfoPanel();
  }

  _restart() {
    this.waveManager.dispose();
    for (const t of this.towers) t.dispose();
    for (const p of this.projectiles) p.dispose();
    this.particleSystem.dispose();
    this.scene.remove(this.gameMap.group);

    this.towers = [];
    this.projectiles = [];
    this.coins = STARTING_COINS;
    this.lives = STARTING_LIVES;
    this.gameOver = false;
    this.victory = false;
    this.speedMultiplier = 1;
    this.selectedTower = null;

    this.gameMap = new GameMap(this.scene);
    this.particleSystem = new ParticleSystem(this.scene);
    this.waveManager = new WaveManager(this.scene, this.gameMap.getPathPoints());

    this.waveManager.onEnemyDeath = (enemy) => {
      this.coins += enemy.reward;
      this.ui.updateCoins(this.coins);
      this.particleSystem.emitAt(enemy.mesh.position, 10, 0xffdd44, 0.6);
    };

    this.waveManager.onEnemyReachEnd = (enemy) => {
      this.lives -= enemy.isBoss ? 5 : 1;
      this.ui.updateLives(this.lives);
      this.particleSystem.emitAt(enemy.mesh.position, 8, 0xff3333, 0.5);
      if (this.lives <= 0) {
        this.lives = 0;
        this.gameOver = true;
        this.ui.showGameOver(() => this._restart());
      }
    };

    this.ui.updateCoins(this.coins);
    this.ui.updateLives(this.lives);
    this.ui.updateWave(0, this.waveManager.totalWaves);
    this.ui.updateSpeed(1);
    this.ui.setWaveButtonState(true);
    this.ui.hideEndScreens();
    this.ui.hideInfoPanel();
    this.ui.deselectTower();
  }

  update(dt) {
    if (this.gameOver || this.victory) return;

    const gameDt = dt * this.speedMultiplier;

    this.gameMap.update(gameDt);
    this.waveManager.update(gameDt);

    const activeEnemies = this.waveManager.getActiveEnemies();

    for (const tower of this.towers) {
      tower.update(gameDt, activeEnemies, this.projectiles);
    }

    for (let i = this.projectiles.length - 1; i >= 0; i--) {
      const proj = this.projectiles[i];
      proj.update(gameDt, activeEnemies, this.particleSystem);
      if (!proj.alive) {
        proj.dispose();
        this.projectiles.splice(i, 1);
      }
    }

    this.particleSystem.update(gameDt);

    this.ui.updateEnemyCount(activeEnemies.length);

    if (this.waveManager.isWaveComplete() && this.waveManager.currentWave >= 0) {
      if (this.waveManager.allWavesComplete) {
        this.victory = true;
        this.ui.showVictory(() => this._restart());
      } else {
        this.ui.setWaveButtonState(true);
      }
    }
  }

  dispose() {
    this.renderer.domElement.removeEventListener('mousemove', this._onMouseMove);
    this.renderer.domElement.removeEventListener('click', this._onClick);
    window.removeEventListener('keydown', this._onKeyDown);

    this.waveManager.dispose();
    for (const t of this.towers) t.dispose();
    for (const p of this.projectiles) p.dispose();
    this.particleSystem.dispose();
    this.ui.dispose();
  }
}
