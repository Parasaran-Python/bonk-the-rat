# BONK THE RAT! — Game Design & Technical Spec

- **Date:** 2026-08-26
- **Status:** Approved design (brainstormed with product owner)
- **Engine:** Godot 4.6.1 stable, GDScript
- **Targets:** Linux (x86_64), Web (HTML5), Android (arm64)
- **Working directory:** repo root = Godot project root

---

## 1. Vision

A modern take on the parlour whack-a-mole cabinet: rats invade a house at
night, the player is the guardian with a mallet. Chunky cartoon visuals drawn
entirely in code, synthesized audio, heavy game-feel ("juice"), 15 levels in
3 themed zones plus an unlockable Endless mode. Fully self-contained repo:
no external asset or plugin dependencies.

**Success criteria for v1**

1. All three exports build and run from a clean checkout.
2. Full 15-level campaign completable; stars, unlocks and scores persist.
3. Endless mode with local Top-10 leaderboard.
4. Headless test suite green (`make test`).
5. A new developer/agent can onboard using only `README.md` + `AGENTS.md` +
   `docs/`.

## 2. Out of scope (v1)

Multiplayer, online leaderboards, monetization/IAP, localization beyond
English, portrait/mobile-UI layouts (landscape only), iOS/macOS/Windows
exports, user-generated content.

---

## 3. Product design

### 3.1 Core loop

Rats pop out of holes → player taps to swing the mallet → bonked rats award
points → chain clean hits to build a combo multiplier → meet the level score
quota before time runs out. Hitting forbidden characters costs lives.

### 3.2 Rat roster

| Character | Behavior | Points | Notes |
|---|---|---|---|
| Norm | Basic rat, standard rise/dive timing | 100 | Present everywhere |
| Zoomer | Fast rise + short up-time | 250 | Zone 2+ |
| Tank | Needs 2 hits; first hit staggers (brief stun) | 300 | Zone 2+ |
| Golden | Rare, very short up-time, sparkle particles | 500 | Zone 3 emphasis |
| Clock | Bonus carrier: bonk freezes timer 5 s | 150 | All zones, rare |
| Star | Bonus carrier: double points 8 s | 150 | All zones, rare |
| Whiskers (cat) | **Must not bonk** | — | Hit = −1 life, mallet stunned 1 s |
| Boom rat | Bomb-carrying rat, fuse visible | — | Bonk = explosion, −1 life; ignoring it is safe |

Bonus carriers' effects stack refresh-wise (new pickup overwrites remaining
time of same effect; Freeze and Double Points can be active simultaneously).

### 3.3 Scoring, combo, lives

- **Combo:** consecutive successful hits raise multiplier ×2 → ×8 (step per
  3 consecutive hits: ×2 at 3, ×4 at 6, ×8 at 9+). A rat escaping un-bonked
  or a forbidden hit breaks the combo. A combo meter drains continuously;
  landing hits refills it — meter empty also breaks the combo.
- **Score popup:** floating "+N ×M" text at hit point.
- **Lives:** 3 per level. Forbidden hit (Whiskers/Boom) = −1 life + screen
  flash + shake. Lives = 0 → immediate fail regardless of score/time.
- **Escaped rats:** no life loss; combo break is the penalty.
- **Missed tap (whiff):** small penalty to combo meter only.

### 3.4 Levels, zones, stars

15 levels × ~40–60 s across 3 zones:

| Zone | Levels | Hole grid | Palette/mood | New elements |
|---|---|---|---|---|
| 1 The Pantry | 1–5 | 3×2 → 3×3 | Warm wood, jam jars | Tutorial on Lv 1 |
| 2 Damp Basement | 6–10 | 3×3 | Cold blues, cobwebs, drip SFX | Zoomer, Tank |
| 3 Midnight Kitchen | 11–15 | 3×3 → 4×3 | Moonlit teal/neon | Boom rat, frequent Goldens |

Star quotas per level: Q1/Q2/Q3 in the level resource. Score ≥ Q1 passes and
unlocks the next level; Q2/Q3 award extra stars. Level select shows earned
stars; Endless unlocks when all Zone 2 levels are passed (≥ Q1).

### 3.5 Endless mode

One continuous escalating session: waves speed up, roster widens, holes all
active. Starts with 3 lives; runs end at 0 lives. Score submits to local
Top-10 (name entry, 3–8 chars). Leaderboard persisted locally.

### 3.6 Screens & flow

Splash → Main Menu (Play / Endless* / Settings / Quit*) → Zone Map →
Level Select → Gameplay (+ Pause overlay) → Results (stars fanfare,
retry / next / map) . First launch auto-plays a ~20 s interactive tutorial:
bonk 3 Norms, then spare an approaching Whiskers (timeout = success).

\* Endless hidden until unlocked; Quit hidden on web/android.

### 3.7 Extras

- **High scores:** per-level best + endless Top-10, persisted locally.
- **Settings:** music volume, SFX volume, screen-shake toggle, reset
  progress (with confirm).
- **Juice:** squash-and-stretch, screen shake (toggleable), impact particles,
  dirt puffs, confetti, haptics on Android via `Input.vibrate_handheld()`
  (guarded by OS permission).

---

## 4. Technical design

### 4.1 Engine configuration

- Viewport **1280×720**, stretch `canvas_items`, aspect `expand`, landscape.
- Renderer: Forward+ desktop / Mobile android / WebGL web (project defaults
  per platform via feature overrides).
- Main scene: `src/screens/Splash.tscn`.

### 4.2 Autoload singletons (contracts)

All cross-system communication is signal-based; autoloads never reach into
each other's UI.

| Autoload | Responsibility | Key API / signals |
|---|---|---|
| `Game` | Run state machine: current LevelConfig, score, lives, combo, power-up timers, quota evaluation | signals: `score_changed(total)`, `combo_changed(mult, fill)`, `life_lost(lives_left)`, `powerup_started(kind, dur)`, `level_finished(result)` ; methods: `start_level(cfg)`, `register_hit(rat)`, `register_escape(rat)` |
| `SaveManager` | Persistence of progress/scores/settings/tutorial flag; atomic writes; corruption → backup + defaults | methods: `get_stars(level_id)`, `set_stars(level_id, n)`, `is_unlocked(level_id)`, `submit_endless(score, name)`, `top_ten()` , settings passthroughs; signal `save_changed` |
| `Settings` | Volumes, shake toggle; applies to audio buses live | signals `changed`; persists via SaveManager |
| `AudioManager` | Pooled SFX players, music crossfade, bus volumes | `play_sfx(name, pitch_jitter)`, `play_music(track)`, `stop_music(fade)` |
| `SceneRouter` | Fade transitions between screens, tiny nav stack for back | `goto(scene_path)`, `back()` |

### 4.3 Project layout

```
project.godot            icon export_presets.cfg Makefile
assets/audio/*.wav       generated by tools (committed)
assets/fonts/            empty in v1 — Godot's built-in default font is used
src/autoload/*.gd        the five singletons
src/screens/*            Splash MainMenu ZoneMap LevelSelect Results Settings Tutorial
src/game/*               Board.tscn Hole.tscn Rat.tscn Mallet.tscn FxLayer Hud.tscn PauseOverlay.tscn
src/data/rat_types.gd    static RatType definitions (id→params dict)
src/data/levels/*.tres   LevelConfig resources level_01..level_15, endless.tres
src/art/*                painter scripts (_draw-based), palette definitions
tools/generate_audio.gd  headless wav synthesizer
tests/run.gd             headless SceneTree test runner; tests/test_*.gd
docs/*.md                documentation set (§6)
```

### 4.4 Data-driven levels

`LevelConfig` (Resource): `duration_s`, `spawn_interval_min/max`,
`spawn_interval_curve` (ramp over level time), `max_concurrent`,
`grid_columns/rows`, `rat_weights` (Dictionary id→weight),
`quota_star1/2/3`, `zone_theme_id`, `music_track`. Board + spawn director
read only this resource — zero hardcoded level logic. Adding a level =
adding a `.tres` (template documented).

### 4.5 Rats

Single `Rat.tscn`; behavior params from `rat_types.gd`
(`rise_time, up_time, sink_time, points, hp, flags[]`). FSM:
`RISING → UP → SINKING → GONE` with interrupts `HIT` and `FLEEING`
(forbidden chars never flee early; Boom shows fuse spark). Motion purely via
tweens. Visual variant selected by id through painters.

### 4.6 Spawn director

Owned by Board. Loop: wait interval (curved) → pick free hole (never
reusing one occupied within last 400 ms) → weighted roll vs current wave
roster → spawn. Respects `max_concurrent`. Deterministic under seeded RNG
for tests.

### 4.7 Input & hit detection

Unified pointer events (mouse/touch). Mallet sprite follows pointer with
slight lag + tilt; tap triggers swing tween. At swing impact frame, manual
circle overlap (mallet head radius vs rat head circle, both in board space)
— no physics engine. Ties resolved nearest-hole-center-first. Whiff if no
overlap.

### 4.8 Art system

Custom `_draw()` painter scripts: `RatPainter` (per-id body variants: ears,
tail whiskers eyes), `MalletPainter`, `HolePainter` (dirt lip, inner
shadow), `BackdropPainter` (zone-themed: shelves/pipes/counters + moon).
Palettes as const dictionaries per zone. Squash/stretch via tweened `scale`;
GPUParticles2D pooled for impact stars, dirt puffs, golden sparkles,
confetti, explosion smoke.

### 4.9 Audio pipeline

`tools/generate_audio.gd` (headless): synthesizes WAVs into
`assets/audio/`: bonk, bonk_heavy, squeak, whiff, yowl, boom, freeze_chime,
star_pickup, combo_1..5 chimes, star_fanfare, ui_click, ui_back, level_win,
level_fail + music loops: menu, zone1 (bouncy), zone2 (moody), zone3
(driving), endless (fast). Committed to git. Runtime only plays files.
Regenerate via `make audio`. Music = short composed loops with tempo/key per
zone mood.

### 4.10 Persistence

`user://save.cfg` (ConfigFile): schema_version, stars{level_id:n},
best_scores{}, endless_top10[{name,score,date}], settings{},
tutorial_seen. Write = temp file + rename (atomic-ish). Read error/corrupt
→ rename to `.bak`, start fresh defaults. Version migration hook present.

### 4.11 Failure handling

- Missing level resource at router time → fall back to level list rebuild.
- Save write failure → in-memory still authoritative this session; warning
  logged.
- Web audio blocked pre-gesture → AudioManager resumes context on first
  input (standard splash tap).

---

## 5. Platforms, testing, delivery

### 5.1 Exports (`export_presets.cfg` committed)

| Target | Notes |
|---|---|
| Linux/X11 x86_64 | primary dev target |
| Web | single-threaded (no COOP/COEP needed), progressive fetch off |
| Android arm64-v8a | landscape locked, debug keystore local-only |

Makefile: `run` `test` `export-linux` `export-web` `export-android`
`audio` `import` `clean`. Exports land in `export/<target>/` (gitignored).

### 5.2 Testing

Headless runner `tests/run.gd` (extends SceneTree), zero plugins:

- Scoring/combo math, quota→stars mapping
- Unlock progression rules (incl. endless gate)
- Save round-trip, corruption recovery, version migration stub
- Spawn director determinism (seeded RNG), concurrency cap, hole reuse rule
- Rat FSM transition table incl. interrupt priority
- Smoke-boot every screen scene headlessly

`make test` must pass before any commit lands.

### 5.3 Git strategy

Conventional commits, GPG signing preserved, branch `main`, no push (remote
added later by owner). Planned sequence:

1. `chore: initialize repository (.gitignore)`
2. `docs: add game design & technical spec`
3. `feat: project scaffold — autoloads, scene routing, main flow`
4. `feat: core gameplay — board, holes, rats, mallet, scoring`
5. `feat: levels, zones, progression, results screens`
6. `feat: endless mode and high-score leaderboard`
7. `feat: settings, tutorial overlay, juice & haptics polish`
8. `test: headless test suite for game logic`
9. `build: export presets for linux/web/android + docs set`

(Exact split may flex while implementing; each commit keeps the project
openable and tests green.)

### 5.4 Documentation set (agent-onboarding first)

| File | Purpose |
|---|---|
| `README.md` | What it is, quickstart (clone→editor→run), controls |
| `AGENTS.md` | Repo map, commands table, conventions, guardrails, "how do I add X" recipes (level, rat type, sound, screen) |
| `docs/GAME_DESIGN.md` | This spec's §3 formalized for designers |
| `docs/ARCHITECTURE.md` | Autoload contracts, signal map, data flow, scene inventory |
| `docs/CONTENT_GUIDE.md` | Tuning levels/roster/themes with copy-paste templates |
| `docs/BUILD_EXPORT.md` | Prereqs + per-platform build/run/test/export steps |
| `docs/ART_AUDIO.md` | Painter system, palettes, audio regen pipeline |

Rule: docs change in the same commit as the code they describe.

---

## 6. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Procedural art looks amateurish | Strict palette discipline, chunky shapes, squash/stretch + particles carry the juice; iterate against screenshots early (commit 4 checkpoint) |
| Web audio autoplay policies | First-input resume pattern on Splash; all audio file-based |
| Android haptics permission friction | Guard behind runtime check; game fully playable without |
| Headless test flakiness on tweens/timers | Tests target pure logic modules (Game math, director, save) not animation frames |
| Scope creep | §2 out-of-scope list is contractual for v1 |
