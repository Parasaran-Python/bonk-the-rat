# BONK THE RAT!

> **Fast-paced arcade whack-a-rat parlour action with zero external assets.**

Built with **Godot 4.6.1 stable** in 100% GDScript.

---

## 🐀 Key Features

- **Zero-Asset Architecture:**
  - 🎨 **100% Procedural Vector Graphics:** Every rat, hole, mallet, background, and UI element is procedurally rendered using CanvasItem vector primitives (`_draw()`).
  - 🔊 **100% Procedurally Synthesized Audio:** 18 distinct sound effects (impacts, squeaks, chimes, fanfares) and 5 multi-track music loops synthesized from pure DSP math via `make audio`.
- **Dynamic 15-Level Campaign & Grid Scaling ($3\times2 \rightarrow 5\times3$):**
  - **Zone 1: The Warm Pantry** (Levels 1–5: $3\times2 \rightarrow 3\times3$ grid)
  - **Zone 2: The Cold Basement** (Levels 6–10: $3\times3 \rightarrow 4\times3$ grid)
  - **Zone 3: The Midnight Kitchen** (Levels 11–15: $4\times3 \rightarrow 5\times3$ grid, up to 15 holes)
- **Roster of Unique Species & Hazards:**
  - **Normal Rat** (+100 pts)
  - **Zoomer Rat** (+150 pts, fast pop speed)
  - **Tank Rat** (+200 pts, requires 2 strikes)
  - **Golden Rat** (+500 pts, rare bonus)
  - **Clock Rat** (Triggers 5.0s Freeze power-up)
  - **Star Rat** (Triggers 7.0s 2X Score Multiplier power-up)
  - **Whiskers the Cat** (Forbidden! Costs 1 Life)
  - **Boom Rat** (Forbidden! Costs 1 Life + Screen Shake)
- **Airborne Flying Rat Bonus Mechanic:**
  - Periodic glider rats swoop across the upper third of the screen in campaign (Levels 4+) and Endless mode.
  - Mid-air strikes award **+1,000 bonus points** plus instant **Freeze** or **2x Score Multiplier** buffs!
- **Deep Combo & Scoring System:**
  - Dynamic combo meter filling up to **8x multiplier**.
  - Whiffing strikes or letting non-forbidden rats escape drops the multiplier.
- **Endless Mode:**
  - Unlocked upon completing Zone 2 on a massive **5x3 grid**.
  - Scaling wave velocity formula ($1.0 + 0.12 \times (\text{wave} - 1)$) and periodic flying rat events.
  - Local Top-10 Leaderboard with custom name entry.
- **Interactive First-Launch Tutorial:**
  - Teaches essential bonking mechanics and cat avoidance rules.
- **Juicy Visuals & Game Feel:**
  - Mahogany mallet with brass rings, leather grip wrap, dynamic swing swoosh trails, and impact squash/recoil.
  - Expressive rat facial animations (autonomous blinking, dazed spiral eyes `@_@`, comic stars on hits).
  - Expanding impact shockwave rings, directional spark bursts, dirt puffs on hole pops, camera shake, hit-stop micro-pauses, and 3-star victory confetti.

---

## 🕹️ Controls

- **Desktop (Mouse):** Left-click on holes or flying rats to swing mallet. `ESC` to toggle pause.
- **Touch / Mobile:** Tap on holes or flying rats to swing mallet.
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
│   ├── game/                  # Gameplay scenes (Board, Hole, Rat, Mallet, HUD, FlyingRat, GameScreen)
│   ├── logic/                 # Pure logic modules (HitTest, Scoring, Progression, SpawnDirector)
│   └── screens/               # UI Screens (Splash, MainMenu, ZoneMap, LevelSelect, Results, Settings)
├── tests/                     # 540+ automated unit & smoke test cases
└── tools/                     # DSP synthesizer, level generator, icon builder
```

---

## 🧪 Testing

The codebase includes an extensive automated test suite run via `make test`:
- `test_harness_selfcheck.gd`: Verifies test assertion framework.
- `test_audio_assets.gd`: Validates presence and header validity of all 18 SFX and 5 music loops.
- `test_level_data.gd`: Verifies 15 campaign levels (up to 5x3 grid) and endless config curves.
- `test_progression.gd`: Validates star thresholds, level unlocks, and chapter requirements.
- `test_scoring.gd`: Tests streak bonuses, multiplier decay, and power-up stacking.
- `test_spawn_director.gd`: Tests deterministic pseudo-random spawn distribution and concurrency caps.
- `test_save.gd`: Validates JSON schema serialization and atomic corruption recovery.
- `test_rat_fsm.gd`: Validates rat lifecycle machine, blinking, and dazed facial expression states.
- `test_mallet.gd`: Validates mallet swing arc animation, swoosh trail, and impact state machine.
- `test_flying_rat.gd`: Validates glider flight kinematics, sinusoidal trajectory, and mid-air strike rewards.
- `test_responsive.gd`: Tests 5x3 board auto-scaling, viewport fitting, and shockwave FX creation.
- `test_game_rules.gd`: Tests Game singleton score, combo, and quota management.
- `test_hit_test.gd`: Tests geometric nearest-neighbor picking with overlap tie-breaking.
- `test_endless_leaderboard.gd`: Tests endless leaderboard ranking and persistence.
- `smoke_board.gd` & `smoke_screens.gd`: Verifies clean instantiation of all game boards, flying actors, and UI screens.
