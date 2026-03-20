/**
 * InputManager - standard keyboard input handling.
 *
 * Direction convention (screen view when camera faces -Z by default):
 * - ArrowLeft / KeyA  -> screen left  -> axis.x -= 1
 * - ArrowRight/ KeyD  -> screen right -> axis.x += 1
 * - ArrowUp   / KeyW  -> forward      -> axis.z -= 1
 * - ArrowDown / KeyS  -> backward     -> axis.z += 1
 *
 * Notes:
 * - Three.js world uses right‑handed coordinates.
 * - These axes are WORLD-relative. Higher-level controls may reinterpret them
 *   relative to camera forward/right vectors.
 */
export class InputManager {
  constructor({ element = window, preventDefault = true } = {}) {
    this.element = element;
    this.preventDefault = preventDefault;
    this.keysDown = new Set();

    this._onKeyDown = (event) => {
      if (this.preventDefault && this._shouldPrevent(event)) {
        event.preventDefault();
      }
      this.keysDown.add(event.code);
      this.keysDown.add(event.key);
    };

    this._onKeyUp = (event) => {
      if (this.preventDefault && this._shouldPrevent(event)) {
        event.preventDefault();
      }
      this.keysDown.delete(event.code);
      this.keysDown.delete(event.key);
    };

    this.element.addEventListener('keydown', this._onKeyDown);
    this.element.addEventListener('keyup', this._onKeyUp);
    this.element.addEventListener('blur', this._onBlur);
    window.addEventListener('blur', this._onBlur);
  }

  _onBlur = () => {
    this.keysDown.clear();
  };

  _shouldPrevent(event) {
    return (
      event.code.startsWith('Arrow') ||
      ['KeyW', 'KeyA', 'KeyS', 'KeyD', 'Space'].includes(event.code)
    );
  }

  isDown(codeOrKey) {
    return this.keysDown.has(codeOrKey);
  }

  // Back-compat alias (matches prior API name).
  isKeyDone(codeOrKey) {
    return this.isDown(codeOrKey);
  }

  /**
   * Returns normalized axis in X/Z plane based on WASD + Arrow keys.
   * x: left(-1) / right(+1)
   * z: forward(-1) / backward(+1)
   */
  getAxis() {
    let x = 0;
    let z = 0;

    if (this.isDown('ArrowLeft') || this.isDown('KeyA') || this.isDown('a')) x -= 1;
    if (this.isDown('ArrowRight') || this.isDown('KeyD') || this.isDown('d')) x += 1;
    if (this.isDown('ArrowUp') || this.isDown('KeyW') || this.isDown('w')) z -= 1;
    if (this.isDown('ArrowDown') || this.isDown('KeyS') || this.isDown('s')) z += 1;

    const length = Math.hypot(x, z);
    if (length > 1e-6) {
      x /= length;
      z /= length;
    }

    return { x, z };
  }

  dispose() {
    this.element.removeEventListener('keydown', this._onKeyDown);
    this.element.removeEventListener('keyup', this._onKeyUp);
    this.element.removeEventListener('blur', this._onBlur);
    window.removeEventListener('blur', this._onBlur);
    this.keysDown.clear();
  }
}
