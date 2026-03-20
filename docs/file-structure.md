# Source File Reference

A quick lookup for every source file in the Empty3D template and its responsibility. Keep this document synchronized with the codebase when files are added, removed, or repurposed.

- `index.html` – Minimal HTML shell with a `#app` mount node that loads `src/main.js` as the module entry point.
- `src/main.js` – Orchestrates the scene by composing helper factories, registering systems, and starting the render loop with cube + keyboard camera updates.
- `src/core/createScene.js` – Builds the `THREE.Scene` and applies the default background color (`#1e1e1e`).
- `src/core/createCamera.js` – Configures the perspective camera (FOV 60, near 0.1, far 100) and positions it at `(0, 1.5, 4)`.
- `src/core/createRenderer.js` – Initializes the WebGL renderer (antialias on, `PCFSoftShadowMap`), clamps pixel ratio to 2, sizes to the window, and mounts the canvas to the given container (defaults to `#app`, falling back to `document.body`).
- `src/core/createLights.js` – Creates the ambient light (intensity 0.35) plus a directional key at `(5, 5, 5)` with shadows configured (2048 map, bounds +/-10, near 0.5, far 50); also exposed as `directional`.
- `src/core/InputManager.js` – Normalizes WASD/Arrow input, prevents default navigation on those keys, clears state on blur, and exposes `isDown` (`isKeyDone` alias)/`getAxis` helpers.
- `src/loop/createRenderLoop.js` – Provides a requestAnimationFrame loop that runs `updatables` with a `delta` time before rendering.
- `src/objects/createShowcaseCube.js` – Returns the hero cube (casts shadows) plus its per-frame rotation update (yaw ~0.6 rad/s, pitch ~0.3 rad/s).
- `src/objects/createFloor.js` – Generates the 6x6 shadow-receiving floor plane beneath the cube and offsets it to `y = -0.5`.
- `src/system/createKeyboardCameraControls.js` – Camera controls driven by the `InputManager`; yaws on left/right or A/D, moves with normalized axes, default `moveSpeed` 3 and `turnSpeed` 1.8, with optional strafing.
- `src/system/setupResize.js` – Syncs camera aspect/renderer size to the browser window on resize events with a 100ms debounce.
- `src/utils/debounce.js` – Lightweight debounce helper used by resize handling.
- `src/styles.css` – Global styles that ensure the canvas fills the viewport, hide overflow, and apply the dark radial gradient + Inter/system font stack.
- `package.json` – Node metadata, dependencies, and npm scripts (`dev`, `build`, `preview`).
- `build.sh` – Helper script that installs dependencies if necessary and runs `npm run build`.
- `docs/developer.md` – Guidance for the developer agent (tech stack, conventions, task recipes).
- `docs/file-structure.md` - this doc.
