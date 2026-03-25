import { WAVES, ENEMY_TYPES } from './GameConfig.js';
import { Enemy } from './Enemy.js';

export class WaveManager {
  constructor(scene, pathPoints) {
    this.scene = scene;
    this.pathPoints = pathPoints;
    this.currentWave = -1;
    this.waveActive = false;
    this.spawners = [];
    this.enemies = [];
    this.onEnemyDeath = null;
    this.onEnemyReachEnd = null;
    this.totalWaves = WAVES.length;
    this.allWavesComplete = false;
  }

  startNextWave() {
    this.currentWave++;
    if (this.currentWave >= WAVES.length) {
      this.allWavesComplete = true;
      return false;
    }

    const wave = WAVES[this.currentWave];
    this.waveActive = true;
    this.spawners = wave.enemies.map(group => ({
      type: group.type,
      remaining: group.count,
      interval: group.interval,
      delay: group.delay,
      timer: group.delay,
    }));

    return true;
  }

  update(dt) {
    if (this.waveActive) {
      for (const spawner of this.spawners) {
        if (spawner.remaining <= 0) continue;

        spawner.timer -= dt;
        if (spawner.timer <= 0) {
          this._spawnEnemy(spawner.type);
          spawner.remaining--;
          spawner.timer = spawner.interval;
        }
      }

      const allSpawned = this.spawners.every(s => s.remaining <= 0);
      const allDead = this.enemies.every(e => !e.alive);
      if (allSpawned && allDead) {
        this.waveActive = false;
      }
    }

    for (let i = this.enemies.length - 1; i >= 0; i--) {
      const enemy = this.enemies[i];
      if (!enemy.alive) {
        if (enemy.reachedEnd) {
          this.onEnemyReachEnd?.(enemy);
        } else if (enemy.hp <= 0) {
          this.onEnemyDeath?.(enemy);
        }
        enemy.dispose();
        this.enemies.splice(i, 1);
        continue;
      }
      enemy.update(dt);
    }
  }

  _spawnEnemy(type) {
    const enemy = new Enemy(type, this.pathPoints, this.scene);
    this.enemies.push(enemy);
  }

  getActiveEnemies() {
    return this.enemies.filter(e => e.alive);
  }

  isWaveComplete() {
    return !this.waveActive;
  }

  dispose() {
    for (const e of this.enemies) {
      e.dispose();
    }
    this.enemies = [];
  }
}
