# BONK THE RAT! — Architecture & Technical Design

## 1. System Overview

**BONK THE RAT!** is a high-performance arcade whack-a-mole game built with Godot 4.6.1 stable, featuring a strict **zero external asset** architecture: all visuals are drawn procedurally via CanvasItem vector primitives (`_draw()`), and all audio effects & music loops are procedurally synthesized via DSP math.

```
+-------------------------------------------------------------------------+
|                              SceneRouter                                |
| (Cross-fade transitions, route stack, navigation history, current_args) |
+-------------------------------------------------------------------------+
       |                  |                  |                  |
       v                  v                  v                  v
  [Splash]           [MainMenu]          [ZoneMap]        [LevelSelect]
                          |                  |                  |
                          +--------+---------+                  |
                                   |                            v
                                   v                     [GameScreen]
                         [EndlessResults] / [Results]   +-------------+
                                                        |   HUD       |
                                                        |   Board     |
                                                        |   Pause     |
                                                        +-------------+
```

---

## 2. Autoload Singletons

The game utilizes five core engine singletons configured in `project.godot`:

1. **`Settings` (`src/autoload/settings.gd`)**:
   - Manages audio volume (`music_volume`, `sfx_volume` in range `0.0..1.0`).
   - Manages screen shake toggle (`shake_enabled`).
   - Emits `changed` signal on property updates for immediate bus dB modulation.

2. **`SaveManager` (`src/autoload/save_manager.gd`)**:
   - Manages atomic save file persistence with automatic corruption recovery (`.tmp` write -> rename; backup corrupt saves to `.bak`).
   - Tracks stars earned per level (1..15), best campaign scores, tutorial completion flag, and local top-10 endless leaderboard records.
   - Emits `save_changed` on modification.

3. **`AudioManager` (`src/autoload/audio_manager.gd`)**:
   - Dedicated `Music` and `SFX` bus routing with logarithmic decibel conversion.
   - 8-player SFX pooling with ±0.06 pitch jitter.
   - Dual-player music engine supporting 0.6s crossfades between zone loops.

4. **`Game` (`src/autoload/game.gd`)**:
   - Authoritative game run state manager: active level config, live score, combo streak, combo meter, lives (3 max), timer, and powerup timers (`freeze_left`, `double_left`).
   - Pure scoring calculations delegated to `Scoring` logic module.

5. **`SceneRouter` (`src/autoload/scene_router.gd`)**:
   - Global screen navigation with a CanvasLayer cross-fade overlay.
   - Preserves route arguments (`current_args`) and scene history stack (`back()`).

---

## 3. Separation of Concerns

```
+--------------------------------------------------------------------------+
| Pure Logic Modules (Unit Tested, RefCounted, zero scene-tree dependency)  |
| - HitTest: Geometric distance picking with tie-breaking                  |
| - Scoring: Combo multipliers, streak thresholds, meter decay rates       |
| - Progression: Unlocks, star thresholds, endless eligibility             |
| - SpawnDirector: Deterministic PRNG rat selection & hole dispatching     |
| - SaveStore: Dictionary serialization, validation, schema migrations     |
+--------------------------------------------------------------------------+
                                     |
                                     v
+--------------------------------------------------------------------------+
| Procedural Painters (Static vector drawing routines)                      |
| - RatPainter: 8 distinct rat/character species + costumes                |
| - HolePainter: 2-pass background cavity & foreground lip drawing         |
| - MalletPainter: Brass-banded wooden hammer with swing rotation          |
| - BackdropPainter: Pantry, Basement, Midnight Kitchen themed backdrops   |
+--------------------------------------------------------------------------+
                                     |
                                     v
+--------------------------------------------------------------------------+
| Scene Actors & UI Flow                                                   |
| - Rat: 6-state FSM (RISING, UP, SINKING, HIT, FLEEING, GONE)             |
| - Hole: Depth-sorted visual container clipping rising rat actors         |
| - Mallet: Pointer/touch tracking hammer with dynamic swing animations     |
| - Board: Grid layout, spawn director tick, input dispatch, juice FX      |
| - FxLayer: CPU particle bursts, screen shake, hit-stop, confetti         |
| - HUD: Tweened counters, combo gauge, powerup vignettes, popups          |
+--------------------------------------------------------------------------+
```

---

## 4. Performance & Memory Guarantees

- **Target Framerate:** Solid 60 FPS on low-end mobile / web browsers.
- **Draw Calls:** Minimal CanvasItem batching via procedural primitive vector calls.
- **Garbage Collection:** Pre-pooled audio players and reused CPUParticles2D nodes.
- **Headless Test Support:** 100% of game logic and scene startup verified in headless CI test runs.
