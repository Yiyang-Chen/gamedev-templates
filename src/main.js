import './styles.css';

import { createCamera } from './core/createCamera.js';
import { createLights } from './core/createLights.js';
import { createRenderer } from './core/createRenderer.js';
import { createScene } from './core/createScene.js';
import { createRenderLoop } from './loop/createRenderLoop.js';
import { createFloor } from './objects/createFloor.js';
import { createShowcaseCube } from './objects/createShowcaseCube.js';
import { InputManager } from './core/InputManager.js';
import { createKeyboardCameraControls } from './system/createKeyboardCameraControls.js';
import { setupResize } from './system/setupResize.js';

const scene = createScene();
const camera = createCamera();
const renderer = createRenderer();

const { ambient, main: mainLight } = createLights();
scene.add(ambient, mainLight);

const { mesh: showcaseCube, update: updateCube } = createShowcaseCube();
scene.add(showcaseCube);

const floor = createFloor();
scene.add(floor);

setupResize({ renderer, camera });

const input = new InputManager();
const cameraControls = createKeyboardCameraControls({ camera, input });

const startRenderLoop = createRenderLoop({
  renderer,
  scene,
  camera,
  updatables: [updateCube, cameraControls.update],
});

startRenderLoop();
