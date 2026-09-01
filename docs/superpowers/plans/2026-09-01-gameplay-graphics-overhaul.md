# BONK THE RAT! Gameplay Progression, Graphics Overhaul & Flying Rat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade BONK THE RAT! with a 15-level dynamic grid ($3\times2 \rightarrow 5\times3$) and speed progression, enhanced procedural mallet/rat graphics with expressive animations and impact shockwaves, and an autonomous flying rat bonus mechanic.

**Architecture:** Procedural CanvasItem vector rendering (`_draw()`), lightweight Tween-driven animation state machines, deterministic SpawnDirector level generation, and modular screen-space hit testing for high-altitude flying actors.

**Tech Stack:** Godot 4.6.1 stable, GDScript 2.0, Headless unit testing harness (`tests/run.gd`).

**Spec:** `docs/superpowers/specs/2026-09-01-gameplay-graphics-overhaul-design.md`

## Global Constraints

- **Strict Zero-Asset Rule:** 100% vector art via `_draw()` CanvasItem routines; no external image files (PNG/JPG/SVG).
- **Headless Compatibility:** All new logic and visual components must instantiate and pass tests headlessly with `make test`.
- **Git & PR Safety:** Work strictly on branch `feature/gameplay-graphics-overhaul`. Never push directly to `main` or merge PRs.

---

### Task 1: Level Progression & Dynamic Grid Tuning ($3\times2 \rightarrow 5\times3$)

**Files:**
- Modify: `tools/generate_levels.gd`
- Modify: `src/data/level_config.gd`
- Modify: `tests/test_level_data.gd`

**Interfaces:**
- Consumes: `LevelConfig`, `RatTypes`, `Progression`
- Produces: `res://src/data/levels/level_01.tres` .. `level_15.tres` and `endless.tres` with $5\times3$ grid dimensions and scaled quotas.

- [ ] **Step 1: Update unit test `tests/test_level_data.gd` to assert $5\times3$ scaling on final levels and endless**

```gdscript
func test_level_progression_grid_dimensions() -> void:
	var l1 := _load(1)
	eq(l1.grid_columns, 3)
	eq(l1.grid_rows, 2)
	var l5 := _load(5)
	eq(l5.grid_columns, 3)
	eq(l5.grid_rows, 3)
	var l10 := _load(10)
	eq(l10.grid_columns, 4)
	eq(l10.grid_rows, 3)
	var l15 := _load(15)
	eq(l15.grid_columns, 5)
	eq(l15.grid_rows, 3)
	var end := load("res://src/data/levels/endless.tres") as LevelConfig
	eq(end.grid_columns, 5)
	eq(end.grid_rows, 3)
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`
Expected: FAIL on grid dimension assertions

- [ ] **Step 3: Update `tools/generate_levels.gd` with the new progression table**

Update `TABLE` in `tools/generate_levels.gd`:
- Lv 1: 3x2, conc 1, iv 1.40->0.95, quotas 700/1300/2000
- Lv 2: 3x2, conc 2, iv 1.30->0.90, quotas 1100/1900/2900
- Lv 3: 3x2, conc 2, iv 1.20->0.85, quotas 1600/2700/4000
- Lv 4: 3x3, conc 3, iv 1.15->0.80, quotas 2100/3500/5200
- Lv 5: 3x3, conc 3, iv 1.10->0.75, quotas 2600/4300/6400
- Lv 6: 3x3, conc 3, iv 1.05->0.70, quotas 3200/5200/7600
- Lv 7: 3x3, conc 3, iv 1.00->0.65, quotas 3800/6100/8900
- Lv 8: 3x3, conc 4, iv 0.95->0.62, quotas 4500/7200/10500
- Lv 9: 4x3, conc 4, iv 0.92->0.58, quotas 5400/8600/12500
- Lv 10: 4x3, conc 4, iv 0.88->0.54, quotas 6300/10000/14500
- Lv 11: 4x3, conc 5, iv 0.82->0.50, quotas 7300/11500/16500
- Lv 12: 4x3, conc 5, iv 0.78->0.46, quotas 8300/13000/18500
- Lv 13: 4x3, conc 5, iv 0.74->0.42, quotas 9400/14700/21000
- Lv 14: 5x3, conc 6, iv 0.70->0.36, quotas 11000/17000/24000
- Lv 15: 5x3, conc 7, iv 0.65->0.30, quotas 13000/20000/28000
- Endless: 5x3, conc 4, iv flat 0.90, base quotas 0/0/0

- [ ] **Step 4: Regenerate level resources and run tests**

Run: `make levels && make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add tools/generate_levels.gd src/data/levels/ tests/test_level_data.gd
git commit -m "feat(levels): scale grid progression up to 5x3 with tuned speed and quotas"
```

---

### Task 2: Board Responsive Layout & $5 \times 3$ Scaling Support

**Files:**
- Modify: `src/game/board.gd`
- Modify: `tests/smoke_board.gd`
- Modify: `tests/test_responsive.gd`

**Interfaces:**
- Consumes: `LevelConfig` ($5\times3$ grid), `Hole`
- Produces: `Board._board_scale`, responsive hole placement on any resolution

- [ ] **Step 1: Write unit test in `tests/test_responsive.gd` for 5x3 grid bounding**

```gdscript
func test_board_5x3_layout_fits_viewport() -> void:
	var board: Node2D = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg := LevelConfig.new()
	cfg.grid_columns = 5
	cfg.grid_rows = 3
	board.setup(cfg)
	board._reposition_holes()
	eq(board._holes.size(), 15)
	for h in board._holes:
		ok(h.position.x > 50.0 and h.position.x < 1230.0, "hole x inside screen bounds")
		ok(h.position.y > 100.0 and h.position.y < 700.0, "hole y inside screen bounds")
	board.queue_free()
```

- [ ] **Step 2: Run test to verify behavior**

Run: `make test`

- [ ] **Step 3: Refine `src/game/board.gd` repositioning math**

Ensure `_reposition_holes()` computes optimal scale and spacing offsets:
```gdscript
var base_spacing_x := 180.0
var base_spacing_y := 135.0
var total_w := float(cols - 1) * base_spacing_x + 180.0
var total_h := float(rows - 1) * base_spacing_y + 140.0
var max_w := vp_size.x * 0.92
var max_h := vp_size.y * 0.54
var scale_w := max_w / total_w if total_w > max_w else 1.0
var scale_h := max_h / total_h if total_h > max_h else 1.0
_board_scale = minf(1.0, minf(scale_w, scale_h))
```

- [ ] **Step 4: Run tests to verify all responsive tests pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/game/board.gd tests/test_responsive.gd
git commit -m "feat(board): support dynamic 5x3 grid auto-scaling and responsive layout"
```

---

### Task 3: Mallet Visuals, Arc Swing & Squash/Recoil Animations

**Files:**
- Modify: `src/art/mallet_painter.gd`
- Modify: `src/game/mallet.gd`
- Create: `tests/test_mallet.gd`
- Modify: `tests/run.gd`

**Interfaces:**
- Consumes: `MalletPainter.draw_mallet(canvas, swing_phase, squash)`
- Produces: Animated swing arc, motion swoosh trail, impact squash, recoil

- [ ] **Step 1: Create failing test `tests/test_mallet.gd`**

```gdscript
extends TestCase

func test_mallet_swing_lifecycle() -> void:
	var mallet: Mallet = load("res://src/game/mallet.tscn").instantiate()
	if root != null:
		root.add_child(mallet)
	mallet.swing_at(Vector2(400, 300))
	eq(mallet.global_position, Vector2(400, 300))
	ok(mallet.is_swinging(), "mallet marked as swinging during strike")
	mallet.queue_free()
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`
Expected: FAIL (`is_swinging` not found)

- [ ] **Step 3: Implement enhanced Mallet visuals in `MalletPainter` and animation in `Mallet`**

1. `MalletPainter.draw_mallet`:
   - Polished mahogany head with top-edge bevel and highlight reflection.
   - Dual metallic brass retention bands with specular shine.
   - Leather grip criss-cross wrap pattern on handle.
   - Motion swoosh arc trail rendered during down-swing.
2. `Mallet.gd`:
   - Add `_swinging` flag, `is_swinging() -> bool`.
   - Tween sequence: $-65^\circ$ anticipation $\rightarrow$ snap $+15^\circ$ strike with squash Vector2(1.25, 0.75) $\rightarrow$ spring recoil bounce back to $0^\circ$ and Vector2.ONE.

- [ ] **Step 4: Run tests to verify pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/art/mallet_painter.gd src/game/mallet.gd tests/test_mallet.gd tests/run.gd
git commit -m "feat(mallet): enhance procedural visuals, arc motion swoosh, and impact squash"
```

---

### Task 4: Expressive Rat Visuals & Facial Animation States

**Files:**
- Modify: `src/art/rat_painter.gd`
- Modify: `src/game/rat.gd`
- Modify: `src/game/rat_visual.gd`
- Modify: `tests/test_rat_fsm.gd`

**Interfaces:**
- Consumes: `Rat.expression_state`, `Rat.blink_timer`
- Produces: Animated blinking eyes, dazed spiral eyes (`@_@`), comic floating stars on hit/stagger

- [ ] **Step 1: Add test in `tests/test_rat_fsm.gd` for expressive states**

```gdscript
func test_rat_expression_state_on_hit() -> void:
	var rat: Rat = load("res://src/game/rat.tscn").instantiate()
	if root != null:
		root.add_child(rat)
	rat.pop_up("tank")
	eq(rat.expression, "normal")
	rat.strike()
	eq(rat.expression, "dazed")
	rat.queue_free()
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`

- [ ] **Step 3: Implement blinking and dazed facial rendering in `RatPainter` and `Rat.gd`**

1. Add `var expression: String = "normal"` to `Rat.gd` (values: `"normal"`, `"blinking"`, `"dazed"`, `"fleeing"`).
2. Set `expression = "dazed"` on `strike()` (both stagger and bonked).
3. In `RatPainter`:
   - Add `_draw_dazed_eyes(canvas, left_pos, right_pos)` drawing spiral arcs and dizzy pupils.
   - Add floating mini stars above head when `dazed`.
   - Add eyelids when `blinking`.
   - Enhance Tank helmet rivets & metal gradient, Zoomer goggle lens reflections, Golden crown jewels, Boom fuse sparks.

- [ ] **Step 4: Run tests to verify pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/art/rat_painter.gd src/game/rat.gd src/game/rat_visual.gd tests/test_rat_fsm.gd
git commit -m "feat(rat): add procedural facial expressions, blinking, dazed spiral eyes and species polish"
```

---

### Task 5: Juice FX — Impact Shockwave Rings & Directional Sparks

**Files:**
- Modify: `src/game/fx_layer.gd`
- Modify: `tests/test_responsive.gd`

**Interfaces:**
- Consumes: `FxLayer.shockwave(pos)`, `FxLayer.impact_sparks(pos)`
- Produces: Polished visual feedback on strikes

- [ ] **Step 1: Write test for shockwave ring creation in `tests/test_responsive.gd`**

```gdscript
func test_fx_shockwave_creation() -> void:
	var fx := FxLayer.new()
	if root != null:
		root.add_child(fx)
	fx.shockwave(Vector2(300, 200), Color("fbbf24"))
	ok(fx.get_child_count() > 0, "shockwave spawned")
	fx.queue_free()
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`

- [ ] **Step 3: Implement shockwave ring & sparks in `FxLayer`**

1. Create shockwave expanding ring via lightweight `Node2D` with `_draw()` ellipse drawing and tweened radius from 8px to 50px with fading alpha.
2. Add directional spark particle burst on `impact()`.

- [ ] **Step 4: Run tests to verify pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/game/fx_layer.gd tests/test_responsive.gd
git commit -m "feat(fx): add expanding impact shockwave rings and directional bonk spark bursts"
```

---

### Task 6: Flying Rat Actor, Flapping Wings & Flight Trajectory

**Files:**
- Create: `src/game/flying_rat.gd`
- Create: `src/game/flying_rat.tscn`
- Modify: `src/art/rat_painter.gd`
- Create: `tests/test_flying_rat.gd`
- Modify: `tests/run.gd`

**Interfaces:**
- Consumes: `RatPainter.draw_flying_rat(canvas, t_anim, is_hit)`
- Produces: Airborne flying rat actor with sine-wave trajectory, flapping wings, mid-air bonk handling

- [ ] **Step 1: Create test `tests/test_flying_rat.gd`**

```gdscript
extends TestCase

func test_flying_rat_trajectory_and_exit() -> void:
	var frat: FlyingRat = load("res://src/game/flying_rat.tscn").instantiate()
	if root != null:
		root.add_child(frat)
	frat.launch(Vector2(-60, 160), Vector2(1, 0), 400.0)
	ok(frat.is_flying(), "flying rat is airborne")
	frat.tick(1.0)
	ok(frat.position.x > 0.0, "flying rat moved forward")
	ok(frat.can_be_hit(), "flying rat is targetable")
	var hit_res := frat.strike()
	eq(hit_res, "bonked")
	ok(not frat.can_be_hit(), "cannot hit after bonk")
	frat.queue_free()
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`

- [ ] **Step 3: Implement `FlyingRat` actor and `RatPainter.draw_flying_rat`**

1. In `RatPainter`:
   - Implement `draw_flying_rat(canvas, t_anim, is_hit)`:
     - Aviator leather flight helmet & pilot goggles.
     - Flapping bat/glider wings (sine wave wing-flap angle).
     - Dangling golden cheese / bonus powerup pouch.
2. In `src/game/flying_rat.gd`:
   - Implement flight physics: $Y(t) = Y_0 + \sin(t \times 4.0) \times 28.0$, horizontal velocity.
   - Screen boundaries check: triggers `escaped` signal when exiting viewport.
   - `strike()`: triggers spin-out tumble exit, emits `bonked(pos, powerup_type)`.

- [ ] **Step 4: Run test to verify pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/game/flying_rat.gd src/game/flying_rat.tscn src/art/rat_painter.gd tests/test_flying_rat.gd tests/run.gd
git commit -m "feat(flying-rat): implement autonomous airborne glider rat actor and flight physics"
```

---

### Task 7: Board Integration & Flying Rat Spawning / Hit Detection

**Files:**
- Modify: `src/game/board.gd`
- Modify: `src/game/game_screen.gd`
- Modify: `tests/test_flying_rat.gd`

**Interfaces:**
- Consumes: `FlyingRat`, `Board.swing_at(pos)`, `Game.on_rat_bonked()`
- Produces: Periodic flying rat spawning in campaign (levels 4+) & endless; mid-air mallet bonks awarding +1,000 pts and powerups.

- [ ] **Step 1: Add integration test in `tests/test_flying_rat.gd` for Board mid-air strike**

```gdscript
func test_board_swings_and_hits_flying_rat() -> void:
	var board: Board = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg: LevelConfig = load("res://src/data/levels/level_04.tres")
	board.setup(cfg)
	var frat := board.spawn_flying_rat_for_test(Vector2(640, 180))
	ok(frat != null, "flying rat spawned on board")
	board.swing_at(Vector2(640, 180))
	ok(not frat.can_be_hit(), "flying rat was hit by mallet swing")
	board.queue_free()
```

- [ ] **Step 2: Run test to verify failure**

Run: `make test`

- [ ] **Step 3: Implement flying rat spawning & hit detection in `Board.gd`**

1. In `Board.gd`:
   - Maintain `_flying_rat: FlyingRat = null`.
   - Timer / trigger in `_process()` spawning a flying rat 1–2 times per level in levels 4+ (and every 25s in Endless).
   - In `swing_at(pos)`: check distance to `_flying_rat.global_position`. If within 65px and `_flying_rat.can_be_hit()`:
     - Strike flying rat, award $+1,000$ points directly to `Game.score`.
     - Trigger powerup buff (Freeze or 2x Double Points) via `Game.powerup_started.emit()`.
     - Trigger `_fx.confetti()`, `_fx.impact()`, `_fx.shockwave()`.
     - Play `AudioManager.play_sfx("star_pickup")` / `"bonk"`.
     - Emit `rat_bonked("flying", 1000, hit_pos)`.

- [ ] **Step 4: Run tests to verify pass**

Run: `make test`
Expected: PASS

- [ ] **Step 5: Commit changes**

```bash
git add src/game/board.gd src/game/game_screen.gd tests/test_flying_rat.gd
git commit -m "feat(board): integrate flying rat event spawning, mid-air hit testing, and bonus rewards"
```

---

### Task 8: Full Verification, Documentation & Pull Request Creation

**Files:**
- Modify: `docs/LEVEL_DESIGN.md`
- Modify: `docs/ART_AUDIO.md`
- Modify: `README.md`
- Modify: `HANDOFF.md`

**Interfaces:**
- Consumes: Complete project codebase
- Produces: Green automated tests, updated documentation, and GitHub Pull Request

- [ ] **Step 1: Update documentation files with new mechanics & level tables**

Update `docs/LEVEL_DESIGN.md`, `docs/ART_AUDIO.md`, and `README.md` to document the 5x3 grid progression, flying rat bonus event, and visual polish.

- [ ] **Step 2: Run full test suite and build verification**

Run: `make test`
Expected: 0 failing cases

- [ ] **Step 3: Commit documentation updates**

```bash
git add docs/ README.md HANDOFF.md
git commit -m "docs: update level design, art documentation, and README for overhaul release"
```

- [ ] **Step 4: Push branch to origin and raise Pull Request**

```bash
git push -u origin feature/gameplay-graphics-overhaul
gh pr create --title "feat: Gameplay Progression, Graphics Overhaul & Flying Rat Mechanic" --body "Comprehensive overhaul adding 5x3 grid progression, enhanced mallet/rat procedural visuals with expressive facial states and shockwaves, and the new Flying Rat bonus mechanic."
```

- [ ] **Step 5: Verify PR status without merging**
