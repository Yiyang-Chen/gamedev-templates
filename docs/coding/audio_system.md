# AudioSystem

BGM and SFX playback. **Never create AudioStreamPlayer nodes manually.**

## BGM (Background Music)

```gdscript
var audio: AudioSystem = EnvironmentRuntime.get_system("AudioSystem") as AudioSystem

# Play background music (loops by default)
audio.play_bgm("bgm_main_theme")
audio.play_bgm("bgm_battle", true, 0.8)  # with loop and volume

# Control BGM
audio.stop_bgm()
audio.pause_bgm()
audio.resume_bgm()
```

## SFX (Sound Effects)

```gdscript
# Fire-and-forget
audio.play_sfx("sfx_click")
audio.play_sfx("sfx_explosion", 0.6)  # with volume
```

SFX only plays if the resource is already cached. The first call triggers a preload for next time.

## Volume and Mute

```gdscript
# Volume control (0.0 ~ 1.0)
audio.set_bgm_volume(0.5)
audio.set_sfx_volume(0.8)

# Mute control
audio.set_muted(true)
```

## Custom Player

Use `create_custom_player()` for sounds that need pause/resume, pitch control, or manual stop (e.g., footsteps, engine sounds, ambient loops):

```gdscript
# Create a custom player (loop=true by default)
var footsteps: AudioStreamPlayer = audio.create_custom_player("walking_ogg", true, 0.3)

# Control the player directly
footsteps.stream_paused = false  # start playing
footsteps.pitch_scale = 1.5      # adjust pitch
footsteps.stream_paused = true   # pause

# Release when done (required)
audio.release_custom_player(footsteps)
```

Custom players **must** be released via `release_custom_player()` when no longer needed.

## Important Notes

- Audio resources must be registered in `game_config.json` (same as other resources)
- Preload audio assets in the loading scene via ResourceSystem for instant playback
- Web audio unlock is handled automatically on user interaction
