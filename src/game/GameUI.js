import { TOWER_TYPES } from './GameConfig.js';

export class GameUI {
  constructor(onTowerSelect, onUpgrade, onSell, onStartWave, onSpeedToggle) {
    this.selectedTowerType = null;
    this.onTowerSelect = onTowerSelect;
    this.onUpgrade = onUpgrade;
    this.onSell = onSell;
    this.onStartWave = onStartWave;
    this.onSpeedToggle = onSpeedToggle;
    this.speedMultiplier = 1;

    this._createHUD();
    this._createTowerPanel();
    this._createUpgradePanel();
    this._createWavePanel();
    this._createMessageOverlay();
  }

  _createHUD() {
    this.hud = document.createElement('div');
    this.hud.id = 'game-hud';
    this.hud.innerHTML = `
      <div class="hud-item">
        <span class="hud-icon">💰</span>
        <span id="gold-display">300</span>
      </div>
      <div class="hud-item">
        <span class="hud-icon">❤️</span>
        <span id="lives-display">20</span>
      </div>
      <div class="hud-item">
        <span class="hud-icon">🌊</span>
        <span id="wave-display">0 / 10</span>
      </div>
      <div class="hud-item">
        <span class="hud-icon">🐛</span>
        <span id="enemy-count-display">0</span>
      </div>
    `;
    document.body.appendChild(this.hud);
  }

  _createTowerPanel() {
    this.towerPanel = document.createElement('div');
    this.towerPanel.id = 'tower-panel';

    const title = document.createElement('div');
    title.className = 'panel-title';
    title.textContent = '🍉 水果防御塔';
    this.towerPanel.appendChild(title);

    const grid = document.createElement('div');
    grid.className = 'tower-grid';

    Object.entries(TOWER_TYPES).forEach(([key, config]) => {
      const btn = document.createElement('button');
      btn.className = 'tower-btn';
      btn.dataset.towerType = key;
      btn.innerHTML = `
        <div class="tower-btn-color" style="background: #${config.color.toString(16).padStart(6, '0')}"></div>
        <div class="tower-btn-name">${config.name}</div>
        <div class="tower-btn-cost">💰 ${config.cost}</div>
        <div class="tower-btn-desc">${config.description}</div>
      `;
      btn.addEventListener('click', () => {
        this._selectTowerType(key, btn);
      });
      grid.appendChild(btn);
    });

    this.towerPanel.appendChild(grid);
    document.body.appendChild(this.towerPanel);
  }

  _selectTowerType(key, btn) {
    document.querySelectorAll('.tower-btn').forEach(b => b.classList.remove('selected'));

    if (this.selectedTowerType === key) {
      this.selectedTowerType = null;
      this.onTowerSelect(null);
    } else {
      this.selectedTowerType = key;
      btn.classList.add('selected');
      this.onTowerSelect(key);
    }
  }

  _createUpgradePanel() {
    this.upgradePanel = document.createElement('div');
    this.upgradePanel.id = 'upgrade-panel';
    this.upgradePanel.style.display = 'none';
    this.upgradePanel.innerHTML = `
      <div class="upgrade-header">
        <span id="upgrade-tower-name"></span>
        <span id="upgrade-tower-level"></span>
      </div>
      <div class="upgrade-stats" id="upgrade-stats"></div>
      <div class="upgrade-actions">
        <button id="upgrade-btn" class="action-btn upgrade-action">⬆️ 升级</button>
        <button id="sell-btn" class="action-btn sell-action">💰 出售</button>
        <button id="close-upgrade-btn" class="action-btn close-action">✖ 关闭</button>
      </div>
    `;
    document.body.appendChild(this.upgradePanel);

    document.getElementById('upgrade-btn').addEventListener('click', () => {
      this.onUpgrade();
    });
    document.getElementById('sell-btn').addEventListener('click', () => {
      this.onSell();
    });
    document.getElementById('close-upgrade-btn').addEventListener('click', () => {
      this.hideUpgradePanel();
    });
  }

  _createWavePanel() {
    this.wavePanel = document.createElement('div');
    this.wavePanel.id = 'wave-panel';
    this.wavePanel.innerHTML = `
      <button id="start-wave-btn" class="wave-btn">▶ 开始下一波</button>
      <button id="speed-btn" class="wave-btn speed-btn">⏩ x1</button>
    `;
    document.body.appendChild(this.wavePanel);

    document.getElementById('start-wave-btn').addEventListener('click', () => {
      this.onStartWave();
    });
    document.getElementById('speed-btn').addEventListener('click', () => {
      this.speedMultiplier = this.speedMultiplier === 1 ? 2 : 1;
      document.getElementById('speed-btn').textContent = `⏩ x${this.speedMultiplier}`;
      this.onSpeedToggle(this.speedMultiplier);
    });
  }

  _createMessageOverlay() {
    this.messageOverlay = document.createElement('div');
    this.messageOverlay.id = 'message-overlay';
    this.messageOverlay.style.display = 'none';
    document.body.appendChild(this.messageOverlay);
  }

  updateGold(gold) {
    document.getElementById('gold-display').textContent = gold;
    document.querySelectorAll('.tower-btn').forEach(btn => {
      const config = TOWER_TYPES[btn.dataset.towerType];
      if (config.cost > gold) {
        btn.classList.add('unaffordable');
      } else {
        btn.classList.remove('unaffordable');
      }
    });
  }

  updateLives(lives) {
    document.getElementById('lives-display').textContent = lives;
  }

  updateWave(current, total) {
    document.getElementById('wave-display').textContent = `${current} / ${total}`;
  }

  updateEnemyCount(count) {
    document.getElementById('enemy-count-display').textContent = count;
  }

  showUpgradePanel(tower) {
    this.upgradePanel.style.display = 'block';
    const config = tower.config;
    const levelNames = ['Lv.1', 'Lv.2', 'Lv.3'];

    document.getElementById('upgrade-tower-name').textContent = config.name;
    document.getElementById('upgrade-tower-level').textContent = levelNames[tower.level];

    const stats = config.levels[tower.level];
    const statsHtml = `
      <div class="stat-row"><span>伤害:</span><span>${stats.damage}</span></div>
      <div class="stat-row"><span>范围:</span><span>${stats.range.toFixed(1)}</span></div>
      <div class="stat-row"><span>攻速:</span><span>${stats.fireRate.toFixed(1)}/s</span></div>
      <div class="stat-row"><span>类型:</span><span>${config.description}</span></div>
    `;
    document.getElementById('upgrade-stats').innerHTML = statsHtml;

    const upgradeBtn = document.getElementById('upgrade-btn');
    const upgradeCost = tower.getUpgradeCost();
    if (upgradeCost !== null) {
      upgradeBtn.style.display = 'block';
      upgradeBtn.textContent = `⬆️ 升级 (💰${upgradeCost})`;
    } else {
      upgradeBtn.style.display = 'none';
    }

    const sellBtn = document.getElementById('sell-btn');
    sellBtn.textContent = `💰 出售 (+${tower.getSellValue()})`;
  }

  hideUpgradePanel() {
    this.upgradePanel.style.display = 'none';
  }

  deselectAllTowers() {
    this.selectedTowerType = null;
    document.querySelectorAll('.tower-btn').forEach(b => b.classList.remove('selected'));
  }

  showMessage(text, duration = 2000) {
    this.messageOverlay.textContent = text;
    this.messageOverlay.style.display = 'flex';
    this.messageOverlay.classList.add('show');

    setTimeout(() => {
      this.messageOverlay.classList.remove('show');
      setTimeout(() => {
        this.messageOverlay.style.display = 'none';
      }, 300);
    }, duration);
  }

  showGameOver(won) {
    const overlay = document.createElement('div');
    overlay.id = 'game-over-overlay';
    overlay.innerHTML = `
      <div class="game-over-content">
        <h1>${won ? '🎉 胜利！' : '💀 失败！'}</h1>
        <p>${won ? '所有害虫都被消灭了！水果王国安全了！' : '害虫突破了防线...'}</p>
        <button id="restart-btn" class="wave-btn" style="font-size:1.2rem; padding:12px 32px;">🔄 重新开始</button>
      </div>
    `;
    document.body.appendChild(overlay);
    document.getElementById('restart-btn').addEventListener('click', () => {
      location.reload();
    });
  }

  setWaveButtonEnabled(enabled) {
    const btn = document.getElementById('start-wave-btn');
    btn.disabled = !enabled;
    btn.style.opacity = enabled ? '1' : '0.5';
  }
}
