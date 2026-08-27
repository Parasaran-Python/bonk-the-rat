# BONK THE RAT!

> **Fast-paced arcade whack-a-rat parlour action with zero external assets.**

Built with **Godot 4.6.1 stable** in 100% GDScript.

---

## 🐀 Key Features

- **Zero-Asset Architecture:**
  - 🎨 **100% Procedural Vector Graphics:** Every rat, hole, mallet, background, and UI element is procedurally rendered using CanvasItem vector primitives (`_draw()`).
  - 🔊 **100% Procedurally Synthesized Audio:** 18 distinct sound effects (impacts, squeaks, chimes, fanfares) and 5 multi-track music loops synthesized from pure DSP math via `make audio`.
- **15-Level Themed Campaign:**
  - **Zone 1: The Warm Pantry** (Levels 1–5)
  - **Zone 2: The Cold Basement** (Levels 6–10)
  - **Zone 3: The Midnight Kitchen** (Levels 11–15)
- **Roster of 8 Unique Species:**
  - **Normal Rat** (+100 pts)
  - **Zoomer Rat** (+150 pts, fast pop speed)
  - **Tank Rat** (+200 pts, requires 2 strikes)
  - **Golden Rat** (+500 pts, rare bonus)
  - **Clock Rat** (Triggers 5.0s Freeze power-up)
  - **Star Rat** (Triggers 7.0s 2X Score Multiplier power-up)
  - **Whiskers the Cat** (Forbidden! Costs 1 Life)
  - **Boom Rat** (Forbidden! Costs 1 Life + Screen Shake)
- **Deep Combo & Scoring System:**
  - Dynamic combo meter filling up to **8x multiplier**.
  - Whiffing strikes or letting non-forbidden rats escape drops the multiplier.
- **Endless Mode:**
  - Unlocked upon completing Zone 2.
  - Scaling wave velocity formula ($1.0 + 0.12 \times (\text{wave} - 1)$).
  - Local Top-10 Leaderboard with custom name entry.
- **Interactive First-Launch Tutorial:**
  - Teaches essential bonking mechanics and cat avoidance rules.
- **Juicy Game Feel:**
  - Dirt puffs on spawn, particle impact bursts, camera shake, hit-stop micro-pauses on heavy strikes, and 3-star victory confetti.

---

## 🕹️ Controls

- **Desktop (Mouse):** Left-click on hole to swing mallet. `ESC` to toggle pause.
- **Touch / Mobile:** Tap on hole to swing mallet.
- **Gamepad / Keyboard:** Supported via Godot virtual cursor & standard input actions.

---

## 🚀 Quick Start

```bash
# 1. Run the game in Godot Editor
make run

# 2. Run the headless automated test suite
make test

# 3. Regenerate procedural audio assets
make audio

# 4. Regenerate level resource configs
make levels

# 5. Build export packages
make export-linux    # Builds Linux standalone x86_64
make export-windows  # Builds Windows standalone x86_64 (.exe)
make export-web      # Builds WebAssembly / HTML5 export
make export-android  # Builds signed Android APK
```

---

## 🌐 Play Online

Play the latest version instantly in your browser (HTML5 / WebAssembly):
👉 **[https://bonk-the-rat.parasaran.in/](https://bonk-the-rat.parasaran.in/)**

---

## 📁 Project Structure

```
hittheratwithmallet/
├── Makefile                   # Automation entry points (run, test, audio, levels, export)
├── project.godot              # Godot project configuration & autoload registration
├── export_presets.cfg         # Linux, Web, and Android export settings
├── assets/audio/              # Procedurally synthesized WAV audio assets
├── docs/
│   ├── ARCHITECTURE.md        # Technical architecture, scene graph & singleton inventory
│   ├── ART_AUDIO.md           # Visual style & DSP synthesis documentation
│   ├── LEVEL_DESIGN.md        # Campaign difficulty curves & endless formulas
│   └── EXPORT_GUIDE.md        # Export instructions for Linux, Web and Android
├── src/
│   ├── art/                   # Procedural vector painters (Rat, Hole, Mallet, Backdrop)
│   ├── autoload/              # Singletons (Settings, SaveManager, AudioManager, Game, SceneRouter)
│   ├── data/                  # LevelConfig resource definition & campaign level configs
│   ├── game/                  # Gameplay scenes (Board, Hole, Rat, Mallet, HUD, GameScreen)
│   ├── logic/                 # Pure logic modules (HitTest, Scoring, Progression, SpawnDirector)
│   └── screens/               # UI Screens (Splash, MainMenu, ZoneMap, LevelSelect, Results, Settings)
├── tests/                     # 350+ automated unit & smoke test cases
└── tools/                     # DSP synthesizer, level generator, icon builder
```

---

## 🧪 Testing

The codebase includes an extensive automated test suite run via `make test`:
- `test_harness_selfcheck.gd`: Verifies test assertion framework.
- `test_audio_assets.gd`: Validates presence and header validity of all 18 SFX and 5 music loops.
- `test_level_data.gd`: Verifies 15 campaign levels and endless config curves.
- `test_progression.gd`: Validates star thresholds, level unlocks, and chapter requirements.
- `test_scoring.gd`: Tests streak bonuses, multiplier decay, and power-up stacking.
- `test_spawn_director.gd`: Tests deterministic pseudo-random spawn distribution and concurrency caps.
- `test_save.gd`: Validates JSON schema serialization and atomic corruption recovery.
- `test_rat_fsm.gd`: Validates 6-state rat lifecycle machine and hit handling.
- `test_game_rules.gd`: Tests Game singleton score, combo, and quota management.
- `test_hit_test.gd`: Tests geometric nearest-neighbor picking with overlap tie-breaking.
- `test_endless_leaderboard.gd`: Tests endless leaderboard ranking and persistence.
- `smoke_board.gd` & `smoke_screens.gd`: Verifies clean instantiation of all game boards and UI screens.
