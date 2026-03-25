import { WAVES } from './GameConfig.js';

export class WaveManager {
  constructor() {
    this.currentWave = -1;
    this.waveActive = false;
    this.spawnQueue = [];
    this.spawnTimer = 0;
    this.enemiesSpawnedThisWave = 0;
    this.totalEnemiesThisWave = 0;
    this.allWavesComplete = false;
  }

  startNextWave() {
    this.currentWave++;
    if (this.currentWave >= WAVES.length) {
      this.allWavesComplete = true;
      return false;
    }

    const wave = WAVES[this.currentWave];
    this.spawnQueue = [];

    for (const group of wave.enemies) {
      for (let i = 0; i < group.count; i++) {
        this.spawnQueue.push({
          type: group.type,
          delay: group.interval,
        });
      }
    }

    this.totalEnemiesThisWave = this.spawnQueue.length;
    this.enemiesSpawnedThisWave = 0;
    this.spawnTimer = 0.5;
    this.waveActive = true;
    return true;
  }

  update(delta) {
    if (!this.waveActive || this.spawnQueue.length === 0) return null;

    this.spawnTimer -= delta;
    if (this.spawnTimer <= 0 && this.spawnQueue.length > 0) {
      const entry = this.spawnQueue.shift();
      this.spawnTimer = entry.delay;
      this.enemiesSpawnedThisWave++;
      return entry.type;
    }

    return null;
  }

  isWaveComplete(activeEnemyCount) {
    return this.waveActive && this.spawnQueue.length === 0 && activeEnemyCount === 0;
  }

  getWaveNumber() {
    return this.currentWave + 1;
  }

  getTotalWaves() {
    return WAVES.length;
  }

  getHealthMultiplier() {
    return 1 + this.currentWave * 0.15;
  }
}
