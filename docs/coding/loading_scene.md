# Loading Scene

`loading.tscn` preloads resources (fonts.pck, etc.) and shows a progress bar.

## Purpose

The loading scene handles asset preloading before the game starts. It uses ResourceSystem to fetch remote resources and displays a progress bar during the process.

## Usage

You can add more resources to preload via ResourceSystem and update the progress bar. Best practice: preload assets needed immediately by the next scene (e.g., main menu background, font PCK).

## Multi-Level Reuse

`loading.tscn` can be called multiple times. For multi-level games, use it to preload level-specific assets before each level via SceneSystem.

## Integration with ResourceSystem

Resources to preload are defined in `game_config.json`. The loading scene iterates over configured resources, calls ResourceSystem to preload them, and updates the progress bar based on completion.
