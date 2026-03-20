import { Vector3 } from 'three';

/**
 * Simple keyboard camera controls.
 * Uses InputManager axes:
 * - axis.x: strafe left/right
 * - axis.z: move forward/back
 * Left/Right also yaw-rotate camera around world Y.
 */
export function createKeyboardCameraControls({
  camera,
  input,
  moveSpeed = 3,
  turnSpeed = 1.8,
  enableStrafe = true,
} = {}) {
  if (!camera) throw new Error('createKeyboardCameraControls: camera is required');
  if (!input) throw new Error('createKeyboardCameraControls: input is required');

  const forward = new Vector3();
  const right = new Vector3();
  const movement = new Vector3();

  const update = (delta = 0) => {
    // Yaw rotation (Q/E or Left/Right or A/D)
    let yaw = 0;
    if (input.isDown('ArrowLeft') || input.isDown('KeyA') || input.isDown('a')) yaw += 1;
    if (input.isDown('ArrowRight') || input.isDown('KeyD') || input.isDown('d')) yaw -= 1;
    if (yaw !== 0) {
      camera.rotation.y += yaw * turnSpeed * delta;
    }

    const axis = input.getAxis();
    if (!enableStrafe) axis.x = 0;

    if (axis.x !== 0 || axis.z !== 0) {
      // Camera-relative forward/right on XZ plane.
      forward.set(0, 0, -1).applyQuaternion(camera.quaternion);
      forward.y = 0;
      forward.normalize();

      right.set(1, 0, 0).applyQuaternion(camera.quaternion);
      right.y = 0;
      right.normalize();

      const forwardAmount = -axis.z; // axis.z is negative when pressing forward
      movement
        .set(0, 0, 0)
        .addScaledVector(right, axis.x)
        .addScaledVector(forward, forwardAmount)
        .multiplyScalar(moveSpeed * delta);

      camera.position.add(movement);
    }
  };

  return { update };
}

