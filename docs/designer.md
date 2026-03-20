# Designer Agent Guide

## Project Snapshot
- Vite + Three.js single page mounted to `#app`; full-screen canvas sits over a dark radial gradient background with the Inter/system font stack loaded.
- Scene contents: ambient + directional light (shadows on), a hero cube slowly rotating on yaw/pitch, and a 6x6 floor plane slightly below the origin receiving shadows.
- Camera: perspective (FOV 60) starting at `(0, 1.5, 4)`; keyboard controls allow yaw (Left/Right or A/D) and movement (WASD/Arrows).
- No external assets or UI chrome; everything renders from code defaults, so new visuals will need to be added explicitly.
- `npm run dev` / `npm run build` work out of the box; no additional setup or downloads are required.

## What You Should Do
- Talk with the client to capture goals, references, desired controls, and performance constraints before proposing visuals.
- Translate the client's asks into concise change requests for the developer agent with priorities and acceptance criteria.
- Keep notes/tickets updated as requests change so everyone is working from the latest direction.
- Stay aligned with scope: do not add features the client didn't request; flag open questions early.
333