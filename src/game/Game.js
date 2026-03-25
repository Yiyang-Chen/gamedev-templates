import * as THREE from 'three';
import { TOWER_TYPES, TILE_TYPES, PLAYER_START_GOLD, PLAYER_START_LIVES } from './GameConfig.js';
import { GameMap } from './GameMap.js';
import { Enemy } from './Enemy.js';
import { Tower } from './Tower.js';
import { Projectile } from './Projectile.js';
import { WaveManager } from './WaveManager.js';
import { ModelFactory } from './ModelFactory.js';
import { GameUI } from './GameUI.js';

export class Game {
  constructor(scene, camera, renderer) {
    this.scene = scene;
    this.camera = camera;
    this.renderer = renderer;

    this.gold = PLAYER_START_GOLD;
    this.lives = PLAYER_START_LIVES;
    this.gameOver = false;
    this.speedMultiplier = 1;

    this.enemies = [];
    this.towers = [];
    this.projectiles = [];
    this.effects = [];

    this.selectedTowerType = null;
    this.selectedTower = null;
    this.hoverIndicator = null;

    this.gameMap = new GameMap(scene);
    this.waveManager = new WaveManager();

    this.ui = new GameUI(
      (type) => this._onTowerTypeSelect(type),
      () => this._onUpgrade(),
      () => this._onSell(),
      () => this._onStartWave(),
      (mult) => { this.speedMultiplier = mult; }
    );

    this.ui.updateGold(this.gold);
    this.ui.updateLives(this.lives);
    this.ui.updateWave(0, this.waveManager.getTotalWaves());

    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();

    this._setupMouseEvents();
    this._createHoverIndicator();

    this.laserBeams = [];
  }

  _createHoverIndicator() {
    const geo = new THREE.BoxGeometry(0.9, 0.05, 0.9);
    const mat = new THREE.MeshBasicMaterial({
      color: 0x44ff44,
      transparent: true,
      opacity: 0.4,
    });
    this.hoverIndicator = new THREE.Mesh(geo, mat);
    this.hoverIndicator.visible = false;
    this.scene.add(this.hoverIndicator);
  }

  _setupMouseEvents() {
    this.renderer.domElement.addEventListener('mousemove', (e) => this._onMouseMove(e));
    this.renderer.domElement.addEventListener('click', (e) => this._onClick(e));
    this.renderer.domElement.addEventListener('contextmenu', (e) => {
      e.preventDefault();
      this._deselect();
    });
  }

  _onMouseMove(e) {
    this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
    this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;

    if (this.selectedTowerType) {
      this.raycaster.setFromCamera(this.mouse, this.camera);
      const intersects = this.raycaster.intersectObjects(this.gameMap.tileObjects);

      if (intersects.length > 0) {
        const tile = intersects[0].object;
        const { col, row, type } = tile.userData;
        const canBuild = (type === TILE_TYPES.BUILDABLE || type === TILE_TYPES.PATH)
          && !this.gameMap.getTileAt(col, row)?.tower;

        const worldPos = this.gameMap.getWorldPos(col, row);
        this.hoverIndicator.position.set(worldPos.x, 0.2, worldPos.z);
        this.hoverIndicator.visible = true;
        this.hoverIndicator.material.color.setHex(canBuild ? 0x44ff44 : 0xff4444);
      } else {
        this.hoverIndicator.visible = false;
      }
    } else {
      this.hoverIndicator.visible = false;
    }
  }

  _onClick(e) {
    this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
    this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;

    this.raycaster.setFromCamera(this.mouse, this.camera);

    if (this.selectedTowerType) {
      this._tryPlaceTower();
      return;
    }

    const towerMeshes = this.towers.map(t => t.mesh);
    const towerIntersects = this.raycaster.intersectObjects(towerMeshes, true);
    if (towerIntersects.length > 0) {
      let obj = towerIntersects[0].object;
      while (obj.parent && !this.towers.find(t => t.mesh === obj)) {
        obj = obj.parent;
      }
      const tower = this.towers.find(t => t.mesh === obj);
      if (tower) {
        this._selectTower(tower);
        return;
      }
    }

    this._deselect();
  }

  _tryPlaceTower() {
    const intersects = this.raycaster.intersectObjects(this.gameMap.tileObjects);
    if (intersects.length === 0) return;

    const tile = intersects[0].object;
    const { col, row, type } = tile.userData;
    const tileData = this.gameMap.getTileAt(col, row);

    if (tileData?.tower) {
      this.ui.showMessage('该位置已有防御塔！');
      return;
    }

    if (type !== TILE_TYPES.BUILDABLE && type !== TILE_TYPES.PATH) {
      this.ui.showMessage('无法在此处建造！');
      return;
    }

    const config = TOWER_TYPES[this.selectedTowerType];
    if (this.gold < config.cost) {
      this.ui.showMessage('金币不足！');
      return;
    }

    const worldPos = this.gameMap.getWorldPos(col, row);
    const tower = new Tower(this.selectedTowerType, col, row, worldPos);
    this.towers.push(tower);
    this.scene.add(tower.mesh);
    this.gameMap.placeTower(col, row, tower);

    this.gold -= config.cost;
    this.ui.updateGold(this.gold);
    this.ui.showMessage(`建造了 ${config.name}！`);

    this._createPlaceEffect(worldPos);
  }

  _createPlaceEffect(pos) {
    const particles = new THREE.Group();
    for (let i = 0; i < 8; i++) {
      const geo = new THREE.SphereGeometry(0.04, 4, 4);
      const mat = new THREE.MeshBasicMaterial({
        color: 0xffdd44,
        transparent: true,
        opacity: 0.8,
      });
      const p = new THREE.Mesh(geo, mat);
      const angle = (i / 8) * Math.PI * 2;
      p.position.set(pos.x + Math.cos(angle) * 0.3, 0.3, pos.z + Math.sin(angle) * 0.3);
      p.userData.velocity = new THREE.Vector3(
        Math.cos(angle) * 1.5,
        2 + Math.random(),
        Math.sin(angle) * 1.5
      );
      particles.add(p);
    }
    this.scene.add(particles);
    this.effects.push({ mesh: particles, life: 0.6, type: 'particles' });
  }

  _selectTower(tower) {
    if (this.selectedTower) {
      this.selectedTower.showRange(false);
    }
    this.selectedTower = tower;
    tower.showRange(true);
    this.ui.deselectAllTowers();
    this.selectedTowerType = null;
    this.ui.showUpgradePanel(tower);
  }

  _deselect() {
    if (this.selectedTower) {
      this.selectedTower.showRange(false);
      this.selectedTower = null;
    }
    this.ui.hideUpgradePanel();
    this.ui.deselectAllTowers();
    this.selectedTowerType = null;
  }

  _onTowerTypeSelect(type) {
    if (this.selectedTower) {
      this.selectedTower.showRange(false);
      this.selectedTower = null;
    }
    this.ui.hideUpgradePanel();
    this.selectedTowerType = type;
  }

  _onUpgrade() {
    if (!this.selectedTower) return;
    const cost = this.selectedTower.getUpgradeCost();
    if (cost === null) {
      this.ui.showMessage('已达最高等级！');
      return;
    }
    if (this.gold < cost) {
      this.ui.showMessage('金币不足！');
      return;
    }
    this.gold -= cost;
    this.selectedTower.totalInvested += cost;
    this.selectedTower.upgrade();
    this.ui.updateGold(this.gold);
    this.ui.showUpgradePanel(this.selectedTower);

    if (this.selectedTower.rangeIndicator) {
      this.selectedTower.showRange(false);
      this.selectedTower.showRange(true);
    }

    this.ui.showMessage('升级成功！');
  }

  _onSell() {
    if (!this.selectedTower) return;
    const refund = this.selectedTower.getSellValue();
    this.gold += refund;

    this.gameMap.removeTower(this.selectedTower.gridCol, this.selectedTower.gridRow);
    this.scene.remove(this.selectedTower.mesh);
    this.selectedTower.dispose();
    this.towers = this.towers.filter(t => t !== this.selectedTower);
    this.selectedTower = null;

    this.ui.updateGold(this.gold);
    this.ui.hideUpgradePanel();
    this.ui.showMessage(`出售成功！获得 ${refund} 金币`);
  }

  _onStartWave() {
    if (this.waveManager.waveActive) {
      this.ui.showMessage('当前波次进行中...');
      return;
    }
    if (this.waveManager.allWavesComplete) {
      this.ui.showMessage('所有波次已完成！');
      return;
    }

    const started = this.waveManager.startNextWave();
    if (started) {
      this.ui.updateWave(this.waveManager.getWaveNumber(), this.waveManager.getTotalWaves());
      this.ui.setWaveButtonEnabled(false);
      this.ui.showMessage(`第 ${this.waveManager.getWaveNumber()} 波来袭！`);
    }
  }

  update(delta) {
    if (this.gameOver) return;

    const dt = delta * this.speedMultiplier;

    const spawnType = this.waveManager.update(dt);
    if (spawnType) {
      this._spawnEnemy(spawnType);
    }

    for (const enemy of this.enemies) {
      enemy.update(dt);
    }

    this._cleanupLaserBeams();

    for (const tower of this.towers) {
      const result = tower.update(dt, this.enemies);
      if (result) {
        if (result.type === 'projectile') {
          this._addProjectile(result);
        } else if (result.type === 'multi') {
          for (const p of result.projectiles) {
            this._addProjectile(p);
          }
        } else if (result.type === 'laser') {
          this._updateLaserBeam(tower, result);
        }
      }
    }

    for (const proj of this.projectiles) {
      const result = proj.update(dt, this.enemies);
      if (result) {
        this._handleProjectileHit(result);
      }
    }

    this._updateEffects(dt);
    this._cleanupDead();

    const activeEnemies = this.enemies.filter(e => e.alive && !e.reachedEnd).length;
    this.ui.updateEnemyCount(activeEnemies);

    if (this.waveManager.isWaveComplete(activeEnemies)) {
      this.waveManager.waveActive = false;
      this.ui.setWaveButtonEnabled(true);

      if (this.waveManager.currentWave >= this.waveManager.getTotalWaves() - 1) {
        this.waveManager.allWavesComplete = true;
        this.gameOver = true;
        this.ui.showGameOver(true);
      } else {
        this.ui.showMessage('波次完成！准备下一波！');
      }
    }
  }

  _spawnEnemy(typeId) {
    const waypoints = this.gameMap.getWorldWaypoints();
    const healthMult = this.waveManager.getHealthMultiplier();
    const enemy = new Enemy(typeId, waypoints, healthMult);
    this.enemies.push(enemy);
    this.scene.add(enemy.mesh);
  }

  _addProjectile(data) {
    const proj = new Projectile(data);
    this.projectiles.push(proj);
    if (proj.mesh) {
      this.scene.add(proj.mesh);
    }
  }

  _handleProjectileHit(result) {
    if (result.type === 'splash') {
      const effect = ModelFactory.createSplashEffect(result.position, result.radius);
      this.scene.add(effect);
      this.effects.push({ mesh: effect, life: 0.3, type: 'splash' });
    }
  }

  _updateLaserBeam(tower, laserData) {
    const existingBeam = this.laserBeams.find(b => b.tower === tower);
    if (existingBeam) {
      this.scene.remove(existingBeam.mesh);
      existingBeam.mesh.geometry.dispose();
      existingBeam.mesh.material.dispose();
    }

    const beam = ModelFactory.createLaserBeam(laserData.from, laserData.to, laserData.color);
    this.scene.add(beam);

    if (existingBeam) {
      existingBeam.mesh = beam;
      existingBeam.life = 0.05;
    } else {
      this.laserBeams.push({ tower, mesh: beam, life: 0.05 });
    }
  }

  _cleanupLaserBeams() {
    for (let i = this.laserBeams.length - 1; i >= 0; i--) {
      const beamData = this.laserBeams[i];
      beamData.life -= 0.016;
      if (beamData.life <= 0) {
        this.scene.remove(beamData.mesh);
        beamData.mesh.geometry.dispose();
        beamData.mesh.material.dispose();
        this.laserBeams.splice(i, 1);
      }
    }
  }

  _updateEffects(dt) {
    for (let i = this.effects.length - 1; i >= 0; i--) {
      const effect = this.effects[i];
      effect.life -= dt;

      if (effect.type === 'particles') {
        effect.mesh.children.forEach(p => {
          p.position.x += p.userData.velocity.x * dt;
          p.position.y += p.userData.velocity.y * dt;
          p.position.z += p.userData.velocity.z * dt;
          p.userData.velocity.y -= 5 * dt;
          p.material.opacity = Math.max(0, effect.life / 0.6);
        });
      } else if (effect.type === 'splash') {
        effect.mesh.material.opacity = Math.max(0, effect.life / 0.3 * 0.6);
        effect.mesh.scale.setScalar(1 + (0.3 - effect.life) * 3);
      }

      if (effect.life <= 0) {
        this.scene.remove(effect.mesh);
        effect.mesh.traverse(child => {
          if (child.isMesh) {
            child.geometry.dispose();
            if (child.material.dispose) child.material.dispose();
          }
        });
        this.effects.splice(i, 1);
      }
    }
  }

  _cleanupDead() {
    for (let i = this.enemies.length - 1; i >= 0; i--) {
      const enemy = this.enemies[i];
      if (!enemy.alive) {
        if (enemy.reachedEnd) {
          this.lives--;
          this.ui.updateLives(this.lives);
          if (this.lives <= 0) {
            this.gameOver = true;
            this.ui.showGameOver(false);
          }
        } else {
          this.gold += enemy.reward;
          this.ui.updateGold(this.gold);
          this._createDeathEffect(enemy.mesh.position);
        }
        this.scene.remove(enemy.mesh);
        enemy.dispose();
        this.enemies.splice(i, 1);
      }
    }

    for (let i = this.projectiles.length - 1; i >= 0; i--) {
      if (!this.projectiles[i].alive) {
        if (this.projectiles[i].mesh) {
          this.scene.remove(this.projectiles[i].mesh);
        }
        this.projectiles[i].dispose();
        this.projectiles.splice(i, 1);
      }
    }
  }

  _createDeathEffect(pos) {
    const particles = new THREE.Group();
    for (let i = 0; i < 6; i++) {
      const geo = new THREE.SphereGeometry(0.03, 4, 4);
      const mat = new THREE.MeshBasicMaterial({
        color: 0xffaa00,
        transparent: true,
        opacity: 1.0,
      });
      const p = new THREE.Mesh(geo, mat);
      p.position.copy(pos);
      const angle = (i / 6) * Math.PI * 2;
      p.userData.velocity = new THREE.Vector3(
        Math.cos(angle) * 2,
        3 + Math.random() * 2,
        Math.sin(angle) * 2
      );
      particles.add(p);
    }

    const coinGeo = new THREE.CylinderGeometry(0.06, 0.06, 0.02, 8);
    const coinMat = new THREE.MeshStandardMaterial({ color: 0xffd700, metalness: 0.8, roughness: 0.2 });
    const coin = new THREE.Mesh(coinGeo, coinMat);
    coin.position.copy(pos);
    coin.position.y += 0.2;
    coin.userData.velocity = new THREE.Vector3(0, 3, 0);
    particles.add(coin);

    this.scene.add(particles);
    this.effects.push({ mesh: particles, life: 0.8, type: 'particles' });
  }
}
