import { TOWER_TYPES, SELL_REFUND_RATIO } from './GameConfig.js';

export class UI {
  constructor(container) {
    this.container = container;
    this.onTowerSelect = null;
    this.onUpgrade = null;
    this.onSell = null;
    this.onStartWave = null;
    this.onSpeedToggle = null;
    this.selectedTowerType = null;

    this._build();
  }

  _build() {
    this.overlay = document.createElement('div');
    this.overlay.id = 'game-ui';
    this.container.appendChild(this.overlay);

    this._buildTopBar();
    this._buildTowerPanel();
    this._buildWavePanel();
    this._buildInfoPanel();
    this._buildGameOverPanel();
    this._buildVictoryPanel();
  }

  _buildTopBar() {
    const bar = document.createElement('div');
    bar.className = 'ui-top-bar';
    bar.innerHTML = `
      <div class="ui-stat">
        <span class="ui-icon">🪙</span>
        <span id="ui-coins">300</span>
      </div>
      <div class="ui-stat">
        <span class="ui-icon">❤️</span>
        <span id="ui-lives">20</span>
      </div>
      <div class="ui-stat">
        <span class="ui-icon">🌊</span>
        <span id="ui-wave">0 / 10</span>
      </div>
      <div class="ui-stat">
        <span class="ui-icon">🐛</span>
        <span id="ui-enemies">0</span>
      </div>
    `;
    this.overlay.appendChild(bar);
  }

  _buildTowerPanel() {
    const panel = document.createElement('div');
    panel.className = 'ui-tower-panel';

    const title = document.createElement('div');
    title.className = 'ui-panel-title';
    title.textContent = '🍓 Fruit Towers';
    panel.appendChild(title);

    const grid = document.createElement('div');
    grid.className = 'ui-tower-grid';

    for (const [key, cfg] of Object.entries(TOWER_TYPES)) {
      const btn = document.createElement('button');
      btn.className = 'ui-tower-btn';
      btn.dataset.type = key;
      btn.innerHTML = `
        <div class="tower-icon">${this._getTowerEmoji(key)}</div>
        <div class="tower-name">${cfg.nameCN}</div>
        <div class="tower-cost">🪙 ${cfg.cost}</div>
      `;
      btn.addEventListener('click', () => {
        this._selectTower(key);
      });
      grid.appendChild(btn);
    }

    panel.appendChild(grid);
    this.overlay.appendChild(panel);
    this.towerPanel = panel;
  }

  _buildWavePanel() {
    const panel = document.createElement('div');
    panel.className = 'ui-wave-panel';

    const startBtn = document.createElement('button');
    startBtn.className = 'ui-wave-btn';
    startBtn.id = 'ui-start-wave';
    startBtn.textContent = '▶ Start Wave';
    startBtn.addEventListener('click', () => {
      this.onStartWave?.();
    });
    panel.appendChild(startBtn);

    const speedBtn = document.createElement('button');
    speedBtn.className = 'ui-speed-btn';
    speedBtn.id = 'ui-speed';
    speedBtn.textContent = '⏩ 1x';
    speedBtn.addEventListener('click', () => {
      this.onSpeedToggle?.();
    });
    panel.appendChild(speedBtn);

    this.overlay.appendChild(panel);
  }

  _buildInfoPanel() {
    const panel = document.createElement('div');
    panel.className = 'ui-info-panel';
    panel.id = 'ui-info-panel';
    panel.style.display = 'none';
    panel.innerHTML = `
      <div class="info-header">
        <span id="info-name">Tower</span>
        <span id="info-level" class="info-level">Lv.1</span>
      </div>
      <div class="info-stats">
        <div>⚔️ Damage: <span id="info-damage">0</span></div>
        <div>📡 Range: <span id="info-range">0</span></div>
        <div>⏱️ Fire Rate: <span id="info-firerate">0</span>/s</div>
      </div>
      <div class="info-actions">
        <button id="info-upgrade" class="info-btn upgrade-btn">⬆️ Upgrade (🪙 <span id="info-upgrade-cost">0</span>)</button>
        <button id="info-sell" class="info-btn sell-btn">💰 Sell (🪙 <span id="info-sell-value">0</span>)</button>
      </div>
    `;
    this.overlay.appendChild(panel);

    document.getElementById('info-upgrade').addEventListener('click', () => {
      this.onUpgrade?.();
    });
    document.getElementById('info-sell').addEventListener('click', () => {
      this.onSell?.();
    });
  }

  _buildGameOverPanel() {
    const panel = document.createElement('div');
    panel.className = 'ui-gameover-panel';
    panel.id = 'ui-gameover';
    panel.style.display = 'none';
    panel.innerHTML = `
      <div class="gameover-content">
        <h1>💀 Game Over</h1>
        <p>The bugs got through!</p>
        <button id="ui-restart" class="ui-restart-btn">🔄 Play Again</button>
      </div>
    `;
    this.overlay.appendChild(panel);
  }

  _buildVictoryPanel() {
    const panel = document.createElement('div');
    panel.className = 'ui-victory-panel';
    panel.id = 'ui-victory';
    panel.style.display = 'none';
    panel.innerHTML = `
      <div class="victory-content">
        <h1>🏆 Victory!</h1>
        <p>All waves defeated! Fruits are safe!</p>
        <button id="ui-victory-restart" class="ui-restart-btn">🔄 Play Again</button>
      </div>
    `;
    this.overlay.appendChild(panel);
  }

  _getTowerEmoji(type) {
    const emojis = {
      strawberry: '🍓',
      watermelon: '🍉',
      lemon: '🍋',
      cherry: '🍒',
      pineapple: '🍍',
    };
    return emojis[type] || '🍎';
  }

  _selectTower(type) {
    this.selectedTowerType = type;
    document.querySelectorAll('.ui-tower-btn').forEach(btn => {
      btn.classList.toggle('selected', btn.dataset.type === type);
    });
    this.hideInfoPanel();
    this.onTowerSelect?.(type);
  }

  deselectTower() {
    this.selectedTowerType = null;
    document.querySelectorAll('.ui-tower-btn').forEach(btn => {
      btn.classList.remove('selected');
    });
  }

  updateCoins(coins) {
    document.getElementById('ui-coins').textContent = coins;
    document.querySelectorAll('.ui-tower-btn').forEach(btn => {
      const type = btn.dataset.type;
      const cost = TOWER_TYPES[type].cost;
      btn.classList.toggle('disabled', coins < cost);
    });
  }

  updateLives(lives) {
    document.getElementById('ui-lives').textContent = lives;
  }

  updateWave(current, total) {
    document.getElementById('ui-wave').textContent = `${current} / ${total}`;
  }

  updateEnemyCount(count) {
    document.getElementById('ui-enemies').textContent = count;
  }

  setWaveButtonState(canStart) {
    const btn = document.getElementById('ui-start-wave');
    btn.disabled = !canStart;
    btn.textContent = canStart ? '▶ Start Wave' : '⏳ Wave in Progress';
  }

  updateSpeed(multiplier) {
    document.getElementById('ui-speed').textContent = `⏩ ${multiplier}x`;
  }

  showInfoPanel(tower) {
    const panel = document.getElementById('ui-info-panel');
    panel.style.display = 'block';

    document.getElementById('info-name').textContent =
      this._getTowerEmoji(tower.type) + ' ' + TOWER_TYPES[tower.type].nameCN;
    document.getElementById('info-level').textContent = `Lv.${tower.level + 1}`;
    document.getElementById('info-damage').textContent = tower.damage.toFixed(0);
    document.getElementById('info-range').textContent = tower.range.toFixed(1);
    document.getElementById('info-firerate').textContent = tower.fireRate.toFixed(1);

    const upgradeBtn = document.getElementById('info-upgrade');
    if (tower.canUpgrade()) {
      upgradeBtn.style.display = 'block';
      document.getElementById('info-upgrade-cost').textContent = tower.getUpgradeCost();
    } else {
      upgradeBtn.style.display = 'none';
    }

    document.getElementById('info-sell-value').textContent = tower.getSellValue();
  }

  hideInfoPanel() {
    document.getElementById('ui-info-panel').style.display = 'none';
  }

  showGameOver(onRestart) {
    document.getElementById('ui-gameover').style.display = 'flex';
    document.getElementById('ui-restart').onclick = onRestart;
  }

  showVictory(onRestart) {
    document.getElementById('ui-victory').style.display = 'flex';
    document.getElementById('ui-victory-restart').onclick = onRestart;
  }

  hideEndScreens() {
    document.getElementById('ui-gameover').style.display = 'none';
    document.getElementById('ui-victory').style.display = 'none';
  }

  dispose() {
    this.overlay.remove();
  }
}
