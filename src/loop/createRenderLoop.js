export function createRenderLoop({ renderer, scene, camera, updatables = [] }) {
  let lastTime = performance.now();

  function render(now = performance.now()) {
    const delta = (now - lastTime) / 1000;
    lastTime = now;

    for (const update of updatables) {
      update?.(delta);
    }

    renderer.render(scene, camera);
    requestAnimationFrame(render);
  }

  return render;
}
