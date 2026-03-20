# Developer Agent Guide

> Keep this document up to date. If the game stack or tooling changes during development, add the details here immediately so the whole team stays aligned.

## Tech Stack Overview
- **Runtime & Tooling**: [Vite](https://vitejs.dev/) builds a pure front-end bundle; hot dev server on port 5173 by default.
- **Rendering flow**: `src/main.js` wires the scene, camera, lights, cube, and floor, mounts the renderer to `#app` (fallback to `document.body`), and starts the requestAnimationFrame loop.
- **Input & controls**: `InputManager` normalizes WASD/Arrow keys and prevents default navigation; `createKeyboardCameraControls` consumes it for movement and yaw rotation.
- **Styling**: `src/styles.css` sets the dark radial gradient backdrop, hides scrollbars, and uses the Inter/system font stack.
- **Scripts**: `npm run dev`, `npm run build`, `npm run preview`, plus `./build.sh` which auto-installs dependencies and runs the production build.

## Current Scene Defaults
- **Scene**: background color `#1e1e1e` (also sits atop the CSS radial gradient).
- **Camera**: Perspective (FOV 60, near 0.1, far 100) positioned at `(0, 1.5, 4)`.
- **Lights**: Ambient white at 0.35; directional white at intensity 1 positioned `(5, 5, 5)` with shadows on (map size 2048x2048, bounds +/-10, near 0.5, far 50).
- **Geometry**: Hero cube (`color: #d1d5db`, roughness 0.35, metalness 0.05) rotating at ~0.6 rad/s yaw and 0.3 rad/s pitch; floor plane (6x6) at `y = -0.5`, receives shadows.
- **Renderer**: Antialias on, `PCFSoftShadowMap`, size synced to window, pixel ratio clamped to `min(devicePixelRatio, 2)`.
- **Loop & resize**: rAF loop passes `delta` seconds to updatables before rendering; resize handler debounced to 100ms updates camera aspect and renderer size.

## Code Conventions
- Use ES Modules everywhere (project `package.json` has `"type": "module"`).
- Keep `src/main.js` tidy: extract reusable objects/utilities into separate modules when complexity grows.
- Favor descriptive names (`mainCamera`, `keyLight`, `heroCube`, etc.) and group related constants (colors, timings, positions) near their usage.
- Keep styles minimal and scoped to the canvas/body unless a new UI element is added.
- Add short comments only when math, shaders, or non-obvious behaviors would trip up the next developer.

## Common Task Recipes
| Task | How to Approach |
| --- | --- |
| Add a new mesh/model | Create a helper module (e.g., `src/objects/createLogo.js`) that returns a configured `THREE.Object3D`, then import it in `main.js` and add it to the scene. |
| Adjust lighting/shadows | Update renderer shadow settings (`renderer.shadowMap`), ensure lights have `castShadow` and meshes set `castShadow/receiveShadow` appropriately, tweak intensities/colors via constants. |
| Animate elements | Use the render loop to track `delta` per frame (already provided) and encapsulate state per object to avoid scattering globals. |
| Camera interaction | Use the built-in keyboard starter (`src/core/InputManager.js` + `src/system/createKeyboardCameraControls.js`) or install/import `OrbitControls` (from `three/examples/jsm/...`); keep sensitivity and limits configurable. |
| Asset loading | Use loaders (`TextureLoader`, `GLTFLoader`, etc.), await/Promise-wrap the loading step, and gate render logic if the asset is required before showing the scene. |

## Keyboard Starter
- `InputManager` defines a standard direction mapping (WASD/Arrow keys), prevents default navigation on those keys, clears state on blur, and exposes `isDown` (`isKeyDone` alias) plus `getAxis()` for normalized X/Z movement.
- `createKeyboardCameraControls` interprets axes relative to camera forward/right on the XZ plane, yaws on Left/Right or A/D (`turnSpeed` 1.8 rad/s), strafes by default (`moveSpeed` 3 units/s).
   

   