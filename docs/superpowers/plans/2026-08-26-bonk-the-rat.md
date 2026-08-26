# BONK THE RAT! Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete arcade whack-a-rat game (15 levels / 3 zones, combos, special rats, power-ups, endless mode, high scores, settings, tutorial, juice) in Godot 4.6, exporting to Linux, Web, and Android.

**Architecture:** Five autoload singletons (`Game`, `SaveManager`, `Settings`, `AudioManager`, `SceneRouter`) coordinate signal-driven screens; all gameplay rules live in dependency-free logic classes under `src/logic/` (unit-tested headlessly); levels are `.tres` resources generated from a tuning table; art is runtime `_draw()` painters; audio is WAVs synthesized once by committed tool scripts.

**Tech Stack:** Godot 4.6.1 stable (`~/.local/bin/godot`), GDScript only, custom SceneTree test runner, Makefile.

**Spec:** `docs/superpowers/specs/2026-08-26-bonk-the-rat-design.md` — read first; this plan argues from it.

## Global Constraints

- Godot **4.6.1**, GDScript only. No C#, no plugins/addons, no downloaded assets.
- Viewport **1280×720**, stretch `canvas_items`, aspect `expand`, landscape.
- Pure logic lives in `src/logic/*.gd` — zero node/scene-tree dependencies so tests run headless.
- Cross-system communication via signals; autoloads never reach into each other's UI.
- Every task ends with: `make test` green, project imports cleanly (`godot --headless --import --path .`), then commit (GPG signing untouched, never push).
- Conventional commits. Docs updated in same commit as code they describe.
- Never commit `.godot/`, exports, keystores (see `.gitignore`).
- Test command: `godot --headless --path . --script tests/run.gd` (wrapped by `make test`).
- File boundary: work only inside this repo (+ `/tmp/opencode` scratch). Default python if ever needed: `/run/media/parasaran/Dev/SDK/python/install/bin/python3.14`.

---

### Task 1: Project scaffold + headless test harness

**Files:**
- Create: `project.godot`, `icon.svg`, `Makefile`
- Create: `src/autoload/{game,save_manager,settings,audio_manager,scene_router}.gd` (stubs)
- Create: `src/screens/splash.gd`, `src/screens/splash.tscn`
- Create: `tests/run.gd`, `tests/test_case.gd`, `tests/test_harness_selfcheck.gd`

**Interfaces:**
- Produces: runnable project booting to Splash; `TestCase` base class (`ok(cond,msg)`, `eq(actual,expected,msg)`, `fail(msg)`, fields `errors:Array[String]`, `checks:int`) that all test modules extend; runner exits 0 green / 1 red; five autoload stubs registered in `project.godot`.

- [ ] **Step 1: Write `project.godot`**

```ini
config_version=5

[application]
config/name="BONK THE RAT!"
config/description="Arcade rat-whacking parlour action"
run/main_scene="res://src/screens/splash.tscn"
config/features=PackedStringArray("4.6")
config/icon="res://icon.svg"

[autoload]
Settings="*res://src/autoload/settings.gd"
SaveManager="*res://src/autoload/save_manager.gd"
AudioManager="*res://src/autoload/audio_manager.gd"
Game="*res://src/autoload/game.gd"
SceneRouter="*res://src/autoload/scene_router.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=4

[input_devices]
pointing/emulate_touch_from_mouse=true

[rendering]
renderer/rendering_method.mobile="mobile"
```

(`orientation=4` = sensor_landscape.) Autoload scripts must exist before this boots.

- [ ] **Step 2: Five autoload stubs** — each like:

```gdscript
extends Node
## Run-state singleton. Implemented in Task 11.
func _ready() -> void: pass
```

with per-file docstrings naming their owning task (save_manager→T6, settings→T7, audio_manager→T8/9, game→T11, scene_router→T13).

- [ ] **Step 3: Splash boot scene** — `src/screens/splash.tscn`: Control root, full-rect anchors, script attached:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/screens/splash.gd" id="1"]

[node name="Splash" type="Control"]
anchors_preset=15
anchor_right=1.0
anchor_bottom=1.0
script=ExtResource("1")
```

```gdscript
extends Control
## Boot screen. Tap-to-start unlocks web audio context.

func _ready() -> void:
	var title := Label.new()
	title.text = "BONK THE RAT!"
	title.set_anchors_preset(Control.PRESET_CENTER)
	add_child(title)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		set_process_input(false)
		print("[splash] start tapped")  # SceneRouter.goto wired in Task 13
```

- [ ] **Step 4: Test harness** — `tests/test_case.gd`:

```gdscript
class_name TestCase
extends RefCounted
## Base for headless test modules. Subclasses define test_*() methods.

var errors: Array[String] = []
var checks := 0

func ok(cond: bool, msg: String) -> void:
	checks += 1
	if not cond:
		errors.append(msg)

func fail(msg: String) -> void:
	ok(false, msg)

func eq(actual: Variant, expected: Variant, msg: String) -> void:
	checks += 1
	if actual != expected:
		errors.append("%s (expected %s, got %s)" % [msg, str(expected), str(actual)])
```

`tests/run.gd`:

```gdscript
extends SceneTree
## godot --headless --path . --script tests/run.gd   Exit 0 = green.

func _initialize() -> void:
	var failures := 0
	var total_checks := 0
	for path in _discover("res://tests"):
		var mod: Object = load(path).new()
		for m in mod.get_method_list():
			if not m.name.begins_with("test_"):
				continue
			mod.errors.clear()
			mod.checks = 0
			mod.call(m.name)
			total_checks += mod.checks
			if not mod.errors.is_empty():
				failures += 1
				print("FAIL %s :: %s" % ["%s:%s" % [path.get_file(), m.name], "; ".join(mod.errors)])
	print("%d checks, %d failing cases" % [total_checks, failures])
	quit(1 if failures > 0 else 0)

func _discover(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir_path)
	if d == null:
		return out
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if f.ends_with(".gd") and f != "test_case.gd" and f != "run.gd":
			out.append(dir_path + "/" + f)
		f = d.get_next()
	out.sort()
	return out
```

`tests/test_harness_selfcheck.gd`:

```gdscript
extends TestCase

func test_math_and_recording() -> void:
	ok(true, "never fires")
	eq(1 + 1, 2, "math works")
	eq(errors.size(), 0, "no errors yet")
```

- [ ] **Step 5: Makefile**

```make
GODOT ?= godot

.PHONY: run import test audio levels export-linux export-web export-android clean

run:
	$(GODOT) --path .

import:
	$(GODOT) --headless --import --path .

test: import
	$(GODOT) --headless --path . --script tests/run.gd

audio:
	$(GODOT) --headless --path . --script tools/generate_audio.gd

levels:
	$(GODOT) --headless --path . --script tools/generate_levels.gd

export-linux: import
	mkdir -p export/linux && $(GODOT) --headless --path . --export-release "Linux" export/linux/bonk-the-rat.x86_64

export-web: import
	mkdir -p export/web && $(GODOT) --headless --path . --export-release "Web" export/web/index.html

export-android: import
	mkdir -p export/android && $(GODOT) --headless --path . --export-release "Android" export/android/bonk-the-rat.apk

clean:
	rm -rf export .godot
```

- [ ] **Step 6: Verify** — `make test` → exit 0, no FAIL lines, checks ≥ 2. Then `timeout 20 $(GODOT) --headless --quit-after 60 --path . 2>&1 | grep -i error` → empty.

- [ ] **Step 7: Commit** — `git add -A && git commit -m "feat: project scaffold and headless test harness"`

---

### Task 2: Scoring & combo logic (TDD)

**Files:** Create `src/logic/scoring.gd`; Test `tests/test_scoring.gd`

**Interfaces:**
- Produces (consumed by T11, T12): `class_name Scoring`; consts `MULT_STEPS:=[3,6,9]`, `MAX_MULT:=8`, `REFILL:=0.25`, `WHIFF_PENALTY:=0.15`, `DRAIN_PER_SEC:=0.08`;
  - `static multiplier_for(consecutive_hits:int)->int` — 1 below 3; ×2 at 3–5; ×4 at 6–8; ×8 at ≥9
  - `static points_for(base_points:int, consecutive_hits:int, double_active:bool)->int`
  - `static stars_for_score(score,q1,q2,q3:int)->int` — 0..3, inclusive thresholds
  - `static meter_after_hit(fill:float)->float` / `meter_after_whiff(fill)` / `meter_after_time(fill,delta)` — clamp [0,1]

- [ ] **Step 1: Failing tests** `tests/test_scoring.gd`

```gdscript
extends TestCase

func test_multiplier_steps() -> void:
	eq(Scoring.multiplier_for(0), 1, "no mult at 0")
	eq(Scoring.multiplier_for(2), 1, "no mult at 2")
	eq(Scoring.multiplier_for(3), 2, "x2 at 3")
	eq(Scoring.multiplier_for(5), 2, "x2 at 5")
	eq(Scoring.multiplier_for(6), 4, "x4 at 6")
	eq(Scoring.multiplier_for(8), 4, "x4 at 8")
	eq(Scoring.multiplier_for(9), 8, "x8 at 9")
	eq(Scoring.multiplier_for(50), 8, "caps at 8")

func test_points_with_combo_and_double() -> void:
	eq(Scoring.points_for(100, 0, false), 100, "base")
	eq(Scoring.points_for(100, 3, false), 200, "x2")
	eq(Scoring.points_for(250, 6, true), 2000, "250 x4 x2")
	eq(Scoring.points_for(500, 12, false), 4000, "golden capped x8")

func test_star_quotas() -> void:
	eq(Scoring.stars_for_score(0, 100, 200, 300), 0, "no stars")
	eq(Scoring.stars_for_score(100, 100, 200, 300), 1, "one star")
	eq(Scoring.stars_for_score(299, 100, 200, 300), 2, "two stars")
	eq(Scoring.stars_for_score(300, 100, 200, 300), 3, "three stars")

func test_meter_math_clamps() -> void:
	eq(Scoring.meter_after_hit(0.9), 1.0, "refill clamps high")
	eq(Scoring.meter_after_whiff(0.1), 0.0, "whiff clamps low")
	ok(absf(Scoring.meter_after_time(1.0, 5.0) - 0.6) < 0.001, "drains 0.08/s")
```

- [ ] **Step 2: Verify failure** — `make test` → FAIL (unknown class Scoring).

- [ ] **Step 3: Implement** exactly per interface above (straightforward static functions; multiplier loops MULT_STEPS doubling; points multiply then double; meter helpers clampf).

- [ ] **Step 4: Green** — `make test`. 
- [ ] **Step 5: Commit** — `git add src/logic/scoring.gd tests/test_scoring.gd && git commit -m "feat: scoring, combo multiplier and star-quota logic"`

---

### Task 3: Progression & unlock rules (TDD)

**Files:** Create `src/logic/progression.gd`; Test `tests/test_progression.gd`

**Interfaces:**
- Produces (consumed by T4, T13, T15): `const LEVEL_COUNT:=15`, `ENDLESS_GATE_LEVEL:=10`;
  - `static is_unlocked(level_id:int, stars:Dictionary)->bool` — id 1 always; id n needs `stars[n-1]>=1`
  - `static endless_unlocked(stars)->bool` — ids 6..10 all ≥1
  - `static total_stars(stars)->int` — ignores non-campaign keys
  - `static next_level_id(id)->int` — id+1 if <15 else −1
  - `static zone_of(id)->int` — ceil(id/5.0)

- [ ] **Step 1: Failing tests** `tests/test_progression.gd`

```gdscript
extends TestCase

func test_first_level_always_unlocked() -> void:
	ok(Progression.is_unlocked(1, {}), "level 1 free")

func test_sequential_unlock() -> void:
	var s := {1: 1}
	ok(Progression.is_unlocked(2, s), "lvl2 after clear")
	ok(not Progression.is_unlocked(3, s), "lvl3 locked")
	s[2] = 1
	ok(Progression.is_unlocked(3, s), "chain continues")

func test_endless_gate_needs_zone2() -> void:
	ok(not Progression.endless_unlocked({6: 3, 7: 1}), "partial insufficient")
	ok(Progression.endless_unlocked({6: 1, 7: 2, 8: 1, 9: 1, 10: 1}), "full zone2 opens endless")

func test_totals_zones_next() -> void:
	eq(Progression.total_stars({1: 3, 2: 1}), 4, "sums campaign keys")
	eq(Progression.next_level_id(7), 8, "next mid-run")
	eq(Progression.next_level_id(15), -1, "campaign end sentinel")
	eq(Progression.zone_of(1), 1, "zone low")
	eq(Progression.zone_of(10), 2, "zone mid")
	eq(Progression.zone_of(15), 3, "zone high")
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement** per interface (trivial static logic).
- [ ] **Step 4: Green.**
- [ ] **Step 5: Commit** — `git add src/logic/progression.gd tests/test_progression.gd && git commit -m "feat: level unlock progression and star totals"`

---

### Task 4: Rat types, LevelConfig resource, 15-level data set

**Files:** Create `src/data/rat_types.gd`, `src/data/level_config.gd`, `tools/generate_levels.gd`; Generate `src/data/levels/level_01..15.tres`, `endless.tres`; Test `tests/test_level_data.gd`

**Interfaces:**
- Produces (consumed everywhere downstream):
  - `RatTypes.TYPES` dict keyed `"norm","zoomer","tank","golden","clock","star","whiskers","boom"`; fields `points,hp,rise,up,sink` (+optional `powerup:String`,`forbidden:bool`). Timings per spec §3.2: norm 0.30/1.00/0.22 pts100; zoomer 0.16/0.55/0.12 pts250; tank hp2 0.34/1.40/0.20 pts300; golden 0.14/0.45/0.10 pts500; clock/star 0.26/0.90/0.18 pts150 powerups freeze/double; whiskers forbidden 0.36/1.10/0.24; boom forbidden fuse-style up 2.20. Statics: `ids()->Array`, `get_type(id:String)->Dictionary`, `is_forbidden(id)->bool`.
  - `class_name LevelConfig extends Resource`; exports `level_id:int, duration_s:float, grid_columns:int, grid_rows:int, max_concurrent:int, spawn_interval_start:float, spawn_interval_end:float, rat_weights:Dictionary, quota_star1:int, quota_star2:int, quota_star3:int, zone_theme:int, music_track:String`; methods `interval_at(progress:float)->float` (=lerp start→end, clamped), `hole_count()->int`.
  - Levels load via `load("res://src/data/levels/level_%02d.tres" % id)`; endless = `endless.tres` with `level_id==0`.

- [ ] **Step 1: Write `rat_types.gd`** verbatim from interface table above.

- [ ] **Step 2: Write `level_config.gd`** per interface (defaults = level 1 values).

- [ ] **Step 3: Write generator** `tools/generate_levels.gd` (SceneTree script; `DirAccess.make_dir_recursive_absolute("res://src/data/levels")`; loop over tuning table constructing LevelConfig and `ResourceSaver.save(cfg, path)`). Tuning table (id,dur,cols,rows,conc,iv0,iv1,weights,q1,q2,q3):

| id | dur | grid | conc | iv0→iv1 | weights | q1/q2/q3 |
|----|-----|------|------|---------|---------|----------|
| 1 | 45 | 3×2 | 1 | 1.40→1.05 | norm95 whiskers5 | 700/1300/2000 |
| 2 | 50 | 3×2 | 2 | 1.30→0.95 | norm92 whiskers7 clock3 | 1100/1900/2900 |
| 3 | 50 | 3×3 | 2 | 1.20→0.85 | norm88 zoomer6 whiskers6 | 1600/2700/4000 |
| 4 | 55 | 3×3 | 3 | 1.15→0.80 | norm84 zoomer8 star4 whiskers4 | 2100/3500/5200 |
| 5 | 60 | 3×3 | 3 | 1.10→0.75 | norm80 zoomer10 star4 whiskers6 | 2600/4300/6400 |
| 6 | 55 | 3×3 | 3 | 1.05→0.72 | norm70 zoomer12 tank6 whiskers6 clock3 | 3200/5200/7600 |
| 7 | 55 | 3×3 | 3 | 1.00→0.68 | norm64 zoomer13 tank9 star4 whiskers6 | 3800/6100/8900 |
| 8 | 60 | 3×3 | 4 | 0.98→0.65 | norm58 zoomer14 tank11 golden3 whiskers6 clock3 | 4500/7200/10500 |
| 9 | 60 | 3×3 | 4 | 0.94→0.62 | norm52 zoomer15 tank12 golden4 star4 whiskers7 | 5200/8300/12100 |
| 10 | 60 | 3×3 | 4 | 0.90→0.58 | norm48 zoomer15 tank13 golden5 star4 whiskers7 clock3 | 6000/9500/13800 |
| 11 | 60 | 4×3 | 4 | 0.88→0.56 | norm44 zoomer15 tank12 boom6 golden5 whiskers6 star3 | 6800/10800/15600 |
| 12 | 60 | 4×3 | 5 | 0.84→0.53 | norm38 zoomer16 tank12 boom7 golden7 whiskers7 clock3 | 7700/12200/17500 |
| 13 | 60 | 4×3 | 5 | 0.80→0.50 | norm33 zoomer17 tank12 boom8 golden8 whiskers7 star3 clock2 | 8600/13600/19500 |
| 14 | 65 | 4×3 | 5 | 0.78→0.48 | norm28 zoomer18 tank13 boom8 golden9 whiskers8 clock3 | 9600/15100/21600 |
| 15 | 65 | 4×3 | 6 | 0.75→0.45 | norm24 zoomer18 tank13 boom8 golden10 whiskers8 star3 clock3 | 10800/17000/24000 |

`zone_theme = Progression.zone_of(id)`; `music_track = "zone%d" % theme`. Endless baseline: id 0, duration 999999, 4×3, conc 4, iv 1.0 flat, weights norm70 zoomer12 tank8 golden4 whiskers6, quotas 0, theme 3, track "endless". Print summary; quit(0).

- [ ] **Step 4: Validation tests** `tests/test_level_data.gd`

```gdscript
extends TestCase

func _load(id: int) -> LevelConfig:
	return load("res://src/data/levels/level_%02d.tres" % id)

func test_all_fifteen_exist_and_valid() -> void:
	for id in range(1, 16):
		var c := _load(id)
		ok(c != null, "level %d exists" % id)
		if c == null: continue
		ok(c.duration_s >= 40.0 and c.duration_s <= 65.0, "%d duration sane" % id)
		ok(c.quota_star1 < c.quota_star2 and c.quota_star2 < c.quota_star3, "%d quotas ascend" % id)
		ok(c.hole_count() >= 6, "%d has holes" % id)
		var sum := 0
		for k in c.rat_weights:
			ok(RatTypes.TYPES.has(k), "%d knows rat '%s'" % [id, k])
			sum += int(c.rat_weights[k])
		ok(sum > 0 and c.rat_weights.has("norm"), "%d weighted basics present" % id)
		eq(c.zone_theme, Progression.zone_of(id), "%d theme matches zone" % id)
		if id <= 2:
			ok(not c.rat_weights.has("tank"), "%d too early for tanks" % id)
			ok(not c.rat_weights.has("boom"), "%d too early for bombs" % id)
	if true:
		var e: LevelConfig = load("res://src/data/levels/endless.tres")
		ok(e != null and e.level_id == 0, "endless resource present")
```

- [ ] **Step 5: Generate + verify** — `make levels && make test` → green.
- [ ] **Step 6: Commit** — `git add src/data tools/generate_levels.gd tests/test_level_data.gd && git commit -m "feat: rat roster, LevelConfig resource and 15-zone campaign data"`

---

### Task 5: Spawn director (TDD, seeded)

**Files:** Create `src/logic/spawn_director.gd`; Test `tests/test_spawn_director.gd`

**Interfaces:**
- Consumes: interval source callable (`LevelConfig.interval_at` bound by Board in T12)
- Produces: `class_name SpawnDirector`; `const HOLE_REUSE_MS := 400`;
  - `setup(seed:int = -1)` (−1 ⇒ randomize)
  - `configure(holes:int, weights:Dictionary, max_concurrent:int)`
  - `set_interval_source(fn: Callable)` — fallback 1.0 s when unset
  - `tick(delta_s:float, active_count:int, progress:float, now_ms:int) -> Dictionary` — `{}` or `{"hole":int,"rat":String}`; enforces cap + cooldown + reuse guard; weighted pick; deterministic under seed

- [ ] **Step 1: Failing tests** `tests/test_spawn_director.gd`

```gdscript
extends TestCase

func _dir(seed_v: int) -> SpawnDirector:
	var d := SpawnDirector.new()
	d.setup(seed_v)
	d.configure(6, {"norm": 100}, 2)
	return d

func test_spawns_when_cool_and_capacity() -> void:
	var r := _dir(1234).tick(10.0, 0, 0.0, 0)
	ok(r.has("rat") and r["rat"] == "norm", "immediate spawn, norm-only table")
	ok(r["hole"] >= 0 and r["hole"] < 6, "valid hole index")

func test_respects_concurrency_cap() -> void:
	var d := _dir(42)
	ok(d.tick(10.0, 0, 0.0, 0).has("rat"), "first")
	ok(d.tick(10.0, 1, 0.0, 100).has("rat"), "second")
	ok(d.tick(10.0, 2, 0.0, 200).is_empty(), "cap blocks third")

func test_respects_cooldown() -> void:
	var d := _dir(7)
	d.configure(6, {"norm": 100}, 5)
	ok(d.tick(0.0, 0, 0.0, 0).has("rat"), "immediate first")
	ok(d.tick(0.1, 0, 0.0, 100).is_empty(), "cooling")
	ok(d.tick(2.0, 0, 0.0, 3000).has("rat"), "fires past interval")

func test_hole_reuse_guard() -> void:
	var d := _dir(99)
	d.configure(1, {"norm": 100}, 5)
	ok(d.tick(10.0, 0, 0.0, 0).has("rat"), "lone hole spawns")
	ok(d.tick(10.0, 0, 0.0, 100).is_empty(), "reuse blocked <400ms")

func test_weighted_distribution_deterministic() -> void:
	var d := SpawnDirector.new()
	d.setup(2024)
	d.configure(6, {"norm": 75, "golden": 25}, 100)
	var goldens := 0
	for i in range(200):
		if d.tick(10.0, 0, 0.0, i * 10000)["rat"] == "golden":
			goldens += 1
	ok(goldens > 20 and goldens < 80, "goldens ~25%%, got %d" % goldens)

func test_same_seed_same_stream() -> void:
	var a := _dir(5); var b := _dir(5)
	for i in range(20):
		eq(a.tick(10.0, 0, 0.0, i * 9000), b.tick(10.0, 0, 0.0, i * 9000), "stream %d" % i)
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement** — internal state: `_rng`, `_cooldown` (decremented per tick), `_last_spawn_ms: Dictionary hole→ms`. Tick order: cooldown check → capacity check → pick fresh hole (skip holes spawned <400 ms ago; −1 if none) → weighted rat roll → record + set cooldown from interval source → return dict.
- [ ] **Step 4: Green.**
- [ ] **Step 5: Commit** — `git add src/logic/spawn_director.gd tests/test_spawn_director.gd && git commit -m "feat: seeded weighted spawn director with reuse guard"`

---

### Task 6: SaveStore + SaveManager (TDD incl. corruption)

**Files:** Create `src/logic/save_store.gd`; Rewrite `src/autoload/save_manager.gd`; Test `tests/test_save.gd`

**Interfaces:**
- Consumes: nothing (pure); SaveManager wraps SaveStore
- Produces:
  - `SaveStore` consts `SCHEMA_VERSION:=1`, `TOP_TEN_SIZE:=10`; statics:
    - `default_data()->Dictionary` → `{schema_version, stars:{}, best_scores:{}, endless_top10:[], tutorial_seen:false}`
    - `serialize(data)->String` (JSON); `deserialize(text)->Dictionary` — **empty Dictionary on any error** (callers test `.is_empty()`)
    - `award_stars(data,id,n)` max-wins; `record_best(data,id,score)` max-wins
    - `submit_endless(data,name,score)` — entry `{name(≤8 chars),score,date}`, sort desc, cap 10
    - `mark_tutorial_seen(data)`
  - `SaveManager` autoload: `SAVE_PATH:="user://save.cfg"` (var, overridable in tests); `load_or_init()` (corrupt→rename `.bak`+defaults+save), `save_now()` (tmp+rename atomic), `get_stars(id)->int`, `get_best(id)->int`, `stars_snapshot()->Dictionary`, `set_result(id,score,stars)`, `top_ten()->Array`, `submit_endless(name,score)->int` (rank 1-based; 0 unplaced), `is_tutorial_seen()->bool`, `mark_tutorial_seen()`, `reset_all()`

- [ ] **Step 1: Failing tests** `tests/test_save.gd`

```gdscript
extends TestCase

func test_roundtrip() -> void:
	var d := SaveStore.default_data()
	d = SaveStore.award_stars(d, 1, 2)
	d = SaveStore.record_best(d, 1, 1234)
	d = SaveStore.mark_tutorial_seen(d)
	var back := SaveStore.deserialize(SaveStore.serialize(d))
	ok(not back.is_empty(), "parses")
	eq(int(back.stars[1]), 2, "stars survive")
	eq(int(back.best_scores[1]), 1234, "best survives")
	ok(back.tutorial_seen, "flag survives")

func test_deserialize_rejects_garbage() -> void:
	ok(SaveStore.deserialize("not json {{{").is_empty(), "garbage rejected")
	ok(SaveStore.deserialize("{\"wrong\":1}").is_empty(), "missing schema rejected")

func test_award_stars_max_wins() -> void:
	var d := SaveStore.default_data()
	d = SaveStore.award_stars(d, 3, 1)
	d = SaveStore.award_stars(d, 3, 3)
	eq(int(d.stars[3]), 3, "max kept")

func test_top_ten_sorted_and_capped() -> void:
	var d := SaveStore.default_data()
	for i in range(15):
		d = SaveStore.submit_endless(d, "AAA", 100 + i * 10)
	eq(d.endless_top10.size(), 10, "capped at 10")
	eq(int(d.endless_top10[0].score), 240, "highest first")

func test_manager_corruption_recovers() -> void:
	var tag := str(Time.get_ticks_msec())
	var path := "user://test_save_%s.cfg" % tag
	var mgr: Node = load("res://src/autoload/save_manager.gd").new()
	mgr.SAVE_PATH = path
	mgr.load_or_init()
	mgr.set_result(1, 500, 2)
	mgr.save_now()
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("CORRUPTED JUNK")
	f = null
	var mgr2: Node = load("res://src/autoload/save_manager.gd").new()
	mgr2.SAVE_PATH = path
	mgr2.load_or_init()
	eq(mgr2.get_stars(1), 0, "fresh defaults after corruption")
	ok(FileAccess.file_exists(path + ".bak"), "backup kept")
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement both files** exactly per interface (SaveManager uses `ProjectSettings.globalize_path` with `DirAccess.rename_absolute` for atomic rename; deserialize-empty ⇒ corrupt path).
- [ ] **Step 4: Green.**
- [ ] **Step 5: Commit** — `git add src/logic/save_store.gd src/autoload/save_manager.gd tests/test_save.gd && git commit -m "feat: persistent save store with atomic writes and corruption recovery"`

---

### Task 7: Settings autoload

**Files:** Rewrite `src/autoload/settings.gd`; Test `tests/test_settings.gd`

**Interfaces:**
- Produces: signal `changed`; vars `music_volume:float=0.8`, `sfx_volume:float=1.0`, `shake_enabled:bool=true`; `SETTINGS_PATH:="user://settings.cfg"` overridable; setters clamp volumes to [0,1], persist immediately via ConfigFile sections `[audio] music/sfx`, `[game] shake`, emit `changed`. AudioManager applies these to buses (T9).

- [ ] **Step 1: Failing tests** `tests/test_settings.gd`

```gdscript
extends TestCase

func test_defaults_and_persistence() -> void:
	var path := "user://test_settings_%d.cfg" % Time.get_ticks_msec()
	var s1: Node = load("res://src/autoload/settings.gd").new()
	s1.SETTINGS_PATH = path
	eq(s1.music_volume, 0.8, "music default")
	eq(s1.sfx_volume, 1.0, "sfx default")
	ok(s1.shake_enabled, "shake default")
	s1.set_music_volume(0.25)
	s1.set_shake_enabled(false)
	var s2: Node = load("res://src/autoload/settings.gd").new()
	s2.SETTINGS_PATH = path
	eq(s2.music_volume, 0.25, "volume persisted")
	ok(not s2.shake_enabled, "shake persisted")

func test_volume_clamps() -> void:
	var s: Node = load("res://src/autoload/settings.gd").new()
	s.SETTINGS_PATH = "user://test_settings_clamp.cfg"
	s.set_music_volume(5.0)
	eq(s.music_volume, 1.0, "clamped high")
	s.set_sfx_volume(-1.0)
	eq(s.sfx_volume, 0.0, "clamped low")
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement** per interface.
- [ ] **Step 4: Green.**
- [ ] **Step 5: Commit** — `git add src/autoload/settings.gd tests/test_settings.gd && git commit -m "feat: settings persistence for volumes and screen shake"`

---

### Task 8: Audio synthesis — SFX library + AudioManager core

**Files:** Create `tools/synth.gd`, `tools/generate_audio.gd`, `assets/audio/*.wav` (~18), stub of `docs/ART_AUDIO.md`; Rewrite `src/autoload/audio_manager.gd` (SFX half; music in T9); Test `tests/test_audio_assets.gd`

**Interfaces:**
- Produces:
  - `Synth` (class_name): `SAMPLE_RATE:=44100`; `buffer(seconds)->PackedFloat32Array`; `osc(buf, freq:Callable(t)->Hz, wave:String["sine","square","saw","tri","noise"], amp, attack_s, release_s)`; `env_adsr(i,n,a,r)->float`; `normalize(buf, peak:=0.85)`; `save_wav(buf, path)` (16-bit mono via `AudioStreamWAV.save_to_wav`); `tone(freq_hz, seconds, wave:="sine", amp:=0.8, slide_to:=0.0)->PackedFloat32Array`
  - Files `res://assets/audio/<n>.wav`: `bonk, bonk_heavy, squeak, whiff, yowl, boom, freeze_chime, star_pickup, combo_1..combo_5, star_fanfare, ui_click, ui_back, level_win, level_fail`
  - `AudioManager`: `play_sfx(name:String, pitch_jitter:=0.06)` round-robin over 8 players (pitch jitter ±); creates `Music`/`SFX` buses in code routed to Master; volume application arrives in T9.

- [ ] **Step 1: Write `tools/synth.gd`** per interface signatures above.
- [ ] **Step 2: Write generator** `tools/generate_audio.gd` (SceneTree script) composing each SFX from Synth primitives:
  - bonk/heavy: sine thump sliding f0→f0·0.3 (180 Hz / 120 Hz) + short noise burst overlay, normalized
  - squeak: square chirp 900→1500 Hz, 0.12 s, amp 0.35
  - whiff: noise sweep 4000→1000 Hz over 0.18 s
  - yowl: two detuned saws sliding 500→240 Hz, 0.45 s
  - boom: sine 90→30 Hz sub 0.6 s + descending noise 1800→300
  - chimes (freeze/star/combo_1..5/fanfare): overlapping triad/arpeggio tri notes, note len 0.16 s, combo bases semitones [0,3,5,7,12] above A4, fanfare C-major stack up an octave
  - ui_click/ui_back: 1200/600 Hz square blips 50/70 ms
  - level_win: rising C-major arpeggio squares ×5 across 0.9 s; level_fail: three falling saw tones (G4→F#4→D#4) over 1.0 s
- [ ] **Step 3: Run** `make audio` → prints done line; `ls assets/audio | wc -l` ≥ 18.
- [ ] **Step 4: Loadability tests** `tests/test_audio_assets.gd`

```gdscript
extends TestCase

const REQUIRED := ["bonk","bonk_heavy","squeak","whiff","yowl","boom",
	"freeze_chime","star_pickup","combo_1","combo_2","combo_3","combo_4","combo_5",
	"star_fanfare","ui_click","ui_back","level_win","level_fail"]

func test_all_sfx_load_nonempty() -> void:
	for n in REQUIRED:
		var s: AudioStream = load("res://assets/audio/%s.wav" % n)
		ok(s != null and s.get_length() > 0.01, "loads non-empty %s" % n)

func test_buses_created() -> void:
	load("res://src/autoload/audio_manager.gd").new()._make_buses()
	ok(AudioServer.get_bus_index("Music") != -1, "Music bus exists")
	ok(AudioServer.get_bus_index("SFX") != -1, "SFX bus exists")
```

(AudioManager must expose `_make_buses()` as plain method so the test can call it before `_ready`.)

- [ ] **Step 5: Green** + create `docs/ART_AUDIO.md` stub (title, purpose, `make audio` regen command).
- [ ] **Step 6: Commit** — `git add tools assets/audio src/autoload/audio_manager.gd tests/test_audio_assets.gd docs/ART_AUDIO.md && git commit -m "feat: synthesized sfx library and audio manager"`

---

### Task 9: Music loops + AudioManager volume wiring

**Files:** Modify `tools/generate_audio.gd` (append music composer), `src/autoload/audio_manager.gd`; Generate `assets/audio/music_{menu,zone1,zone2,zone3,endless}.wav`; Test: extend `tests/test_audio_assets.gd`

**Interfaces:**
- Produces:
  - Music files >3 s each, 4-bar loops. Moods per spec §4.9: menu 96 BPM gentle tri; zone1 112 BPM bouncy square lead + walking bass + hats; zone2 88 BPM sparse saw pad minor; zone3 126 BPM driving bass 8ths + arp; endless 140 BPM faster variant.
  - `AudioManager.play_music(track:String)` — crossfades 0.8 s between two pooled players; sets `AudioStreamWAV.loop_mode = LOOP_FORWARD` (`loop_end = data.size()/2`) on play; `stop_music(fade:=1.0)`; `_apply_volumes()` maps `Settings.music_volume/sfx_volume` to bus dB via `linear_to_db`, re-applied on `Settings.changed`.

- [ ] **Step 1: Append to generator** — shared helper `_render_track(fname, bpm, bass:Array[[beat,freq,len_beats]], lead:Array[...], lead_wave:String, hats:bool)` rendering overlapping Synth notes into one buffer (mix at `beat*spb*SR`, spb=60/bpm, total=16 beats) + optional noise hats each beat; then compose five tracks from note tables (A=220 Hz reference via `220*pow(2, semi/12)`):
  - menu: bass A2 whole/half notes; tri lead C4-E4-G4 half notes; no hats
  - zone1: walking bass A2/A2/E3 pattern quarter-notes ×8; square lead arpeggio A4-C#5-E5-C#5… eighths; hats on
  - zone2: D-minor pads D2/F2/A2/C3 whole notes; sparse saw D4-F4-A3 long tones; no hats
  - zone3: E-minor driving bass alternating E2/B2 eighth-notes ×16; square arp E5-D5-B4-D5 / E5-F#5-G5… ; hats
  - endless: same engine, 140 BPM, denser lead sixteenth-figures
  GDScript has no list comprehensions — build note arrays with plain for-loops before calling the renderer.
- [ ] **Step 2: Wire AudioManager** per interface (two AudioStreamPlayers `_music_a/_music_b`, `_music_current` swap, create_tween parallel volume tweens, outgoing stop callback).
- [ ] **Step 3: Extend tests**

```gdscript
func test_music_tracks_load() -> void:
	for t in ["menu", "zone1", "zone2", "zone3", "endless"]:
		var s: AudioStream = load("res://assets/audio/music_%s.wav" % t)
		ok(s != null and s.get_length() > 3.0, "music %s present >3s" % t)
```

Run `make audio && make test` → green.
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: zone music loops and bus-aware audio manager"`

---

### Task 10: Palettes, painters, Rat scene + FSM

**Files:** Create `src/art/palettes.gd`, `src/art/rat_painter.gd`, `src/art/hole_painter.gd`, `src/art/mallet_painter.gd`, `src/art/backdrop_painter.gd`; Create `src/game/rat.gd`, `src/game/rat.tscn`; Test `tests/test_rat_fsm.gd`

**Interfaces:**
- Produces:
  - `Palettes.for_zone(theme:int)->Dictionary` keys `bg,bg_dark,accent,wood,dirt,shadow`. Zone1 warm pantry (`bg e8c07a`, accent `d94f30`); zone2 cold basement (`bg 4a5e75`, accent `63c5b5`); zone3 midnight kitchen (`bg 27343f`, accent `ffd166`). Exact hex values chosen in-task, documented in file header.
  - `RatPainter.draw_rat(canvas: CanvasItem, id: String, squash := Vector2.ONE)` — chunky cartoon bodies via draw_circle/draw_polygon/polyline; distinct silhouettes: whiskers = slate cat with triangle ears + white whiskers + pink nose + green eyes; boom = gray rat carrying black bomb sphere with amber fuse spark; golden = gold fur + white star sparkles ring; tank = 1.25× scale dark brown; zoomer = lean orange-brown. All shapes flat-color, no textures.
  - `HolePainter.draw_hole(c, theme)` dark ellipse rx62 ry20 + dirt lip polyline; `draw_rim_front(c, theme)` lower-lip redraw pass (depth).
  - `MalletPainter.draw_mallet(c)` wooden handle 10×70 + red capsule head 64×36 with cream band, head leading upward.
  - `BackdropPainter.draw_backdrop(c, theme, size)` zone1 shelf+jar blobs / zone2 brick courses+drip pipe / zone3 counter+moon window+neon accents — flat polygons only.
  - `class_name Rat extends Node2D`; `enum State {RISING, UP, SINKING, HIT, FLEEING, GONE}`; signals `bonked(rat)`, `escaped(rat)`, `despawned(rat)`; `state`, `rat_id`, `hp_left`; `static can_transition(from,to)->bool` (GONE terminal; HIT allowed from RISING/UP/SINKING); `pop_up(id:String, speed_scale:=1.0)` tween chain rise→interval→sink→despawn; `strike()->int` returns remaining hp (0 ⇒ HIT squash-die); `flee_early()` (UP⇒FLEEING fast dive, emits escaped); DOWN_OFFSET 130 px; all motion via tweens.

- [ ] **Step 1: Failing FSM tests** `tests/test_rat_fsm.gd`

```gdscript
extends TestCase

func test_legal_flow() -> void:
	ok(Rat.can_transition(Rat.State.RISING, Rat.State.UP), "rise->up")
	ok(Rat.can_transition(Rat.State.UP, Rat.State.SINKING), "up->sink")
	ok(Rat.can_transition(Rat.State.SINKING, Rat.State.GONE), "sink->gone")

func test_interrupts_from_active_states() -> void:
	for s in [Rat.State.RISING, Rat.State.UP, Rat.State.SINKING]:
		ok(Rat.can_transition(s, Rat.State.HIT), "hit interrupts state %d" % s)

func test_gone_is_terminal() -> void:
	ok(not Rat.can_transition(Rat.State.GONE, Rat.State.UP), "no zombie rats")
	ok(not Rat.can_transition(Rat.State.HIT, Rat.State.RISING), "hit is terminal entry")

func test_rat_scene_instantiates_and_strikes_synchronously() -> void:
	var r: Rat = load("res://src/game/rat.tscn").instantiate()
	r.rat_id = "tank"          # set before _draw paths run headless
	# synchronous FSM checks without awaiting tweens:
	eq(int(r.state), int(Rat.State.GONE), "starts GONE")
	r.free()
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement palettes + painters** per interface (this is the visual heart — take care: consistent stroke widths, symmetric features, squash param applied via `canvas.draw_set_transform(Vector2.ZERO, 0, squash)` wrapper).
- [ ] **Step 4: Implement Rat scene** per interface. `.tscn`: root Node2D script rat.gd + child `Visual` Node2D with inline `_draw()` calling `RatPainter.draw_rat(self, owner_node.rat_id, owner_node.scale_visual())`; root calls `$Visual.queue_redraw()` after pop_up/strike/stagger/scale changes.
- [ ] **Step 5: Green** — synchronous assertions only (tween timing is not unit-tested; Board smoke covers it in T12).
- [ ] **Step 6: Commit** — `git add src/art src/game/rat.gd src/game/rat.tscn tests/test_rat_fsm.gd && git commit -m "feat: procedural rat art, palettes and rat state machine"`

---

### Task 11: Game autoload state machine (TDD)

**Files:** Rewrite `src/autoload/game.gd`; Test `tests/test_game_rules.gd`

**Interfaces:**
- Consumes: `Scoring`, `LevelConfig`, `RatTypes`; SaveManager/AudioManager only when not `test_mode`
- Produces (consumed by T12–T15):
  - Signals: `score_changed(total:int)`, `combo_changed(mult:int, fill:float)`, `lives_changed(lives:int)`, `time_left_changed(sec:float)`, `powerup_started(kind:String, dur:float)`, `level_ended(result:Dictionary)` result keys `{mode,won,score,stars,best_combo}`
  - Methods/vars: `start_level(cfg)`, `start_endless()`, `on_rat_bonked(rat_id)->int` (awarded points), `on_rat_escaped(id)`, `on_forbidden_hit()`, `on_whiff()`, `tick(delta)`, `active()->bool`, `remaining_time()->float`, `endless_wave()->int`, `current_mult()->int`, `check_end_conditions()`, vars `score, lives, combo_hits, meter, double_active, best_combo, mode("campaign"/"endless"), cfg, test_mode`
  - Rules (spec §3.3): START_LIVES=3; forbidden hit −1 life + combo reset; escape/whiff/meter-empty reset combo (whiff only −0.15 meter); FREEZE_SECONDS=5 (pauses time drain), DOUBLE_SECONDS=8 (×2 points), refresh-overwrite semantics; campaign ends timeout (win iff stars≥1; life-loss forfeits stars) or lives 0 (fail, stars 0); endless untimed, ends lives 0; WAVE_SCORE_STEP=500 → wave = score/500+1

- [ ] **Step 1: Failing tests** `tests/test_game_rules.gd`

```gdscript
extends TestCase

func _game() -> Node:
	var g: Node = load("res://src/autoload/game.gd").new()
	g.test_mode = true
	return g

func test_campaign_scores_combo_and_double() -> void:
	var g := _game()
	g.start_level(load("res://src/data/levels/level_01.tres"))
	eq(g.on_rat_bonked("norm"), 100, "first hit base")
	eq(g.on_rat_bonked("norm"), 100, "still x1")
	g.combo_hits = 1
	eq(g.on_rat_bonked("norm"), 200, "x2 kicks in")
	eq(g.score, 400, "total accumulates")
	g.double_active = true
	eq(g.on_rat_bonked("norm"), 800, "double applies to x4")

func test_escape_breaks_combo_not_lives() -> void:
	var g := _game()
	g.start_level(load("res://src/data/levels/level_01.tres"))
	for i in range(3): g.on_rat_bonked("norm")
	eq(g.current_mult(), 2, "heated up")
	g.on_rat_escaped("norm")
	eq(g.current_mult(), 1, "combo broken")
	eq(g.lives, 3, "escapes cost no life")

func test_forbidden_hit_costs_life_fail_forfeits_stars() -> void:
	var g := _game()
	g.start_level(load("res://src/data/levels/level_01.tres"))
	var ended := []
	g.level_ended.connect(func(r): ended.append(r))
	while g.lives > 0: g.on_forbidden_hit()
	eq(ended.size(), 1, "ended fired once")
	ok(not ended[0].won, "lost at 0 lives")
	eq(int(ended[0].stars), 0, "fail forfeits stars even with score")
	ok(ended[0].best_combo >= 0, "result carries stats")

func test_timeout_evaluates_quota_win() -> void:
	var g := _game()
	var ended := []
	g.level_ended.connect(func(r): ended.append(r))
	g.start_level(load("res://src/data/levels/level_01.tres"))
	g.score = 700  # exactly Q1 of level_01
	g.tick(999.0)
	eq(ended.size(), 1, "timeout ends")
	ok(ended[0].won, "quota met = win")
	eq(int(ended[0].stars), 1, "one star")

func test_powerups_freeze_and_double() -> void:
	var g := _game()
	g.start_level(load("res://src/data/levels/level_01.tres"))
	var started := []
	g.powerup_started.connect(func(k, d): started.append([k, d]))
	eq(g.on_rat_bonked("clock"), 150, "clock pays base x1")
	eq(started.size(), 1, "freeze fired"); eq(started[0][0], "freeze", "kind")
	eq(started[0][1], 5.0, "freeze 5s")
	var before: float = g.remaining_time()
	g.tick(2.0)
	eq(absf(g.remaining_time() - before) < 0.001, true, "time frozen")
	eq(g.on_rat_bonked("star"), 300, "star pays doubled at x2")
	ok(g.double_active, "double active")
	g._freeze_left = 0.0
	g.tick(8.5)
	ok(not g.double_active, "double expires")

func test_meter_drain_breaks_combo() -> void:
	var g := _game()
	g.start_level(load("res://src/data/levels/level_01.tres"))
	for i in range(3): g.on_rat_bonked("norm")
	g.meter = 0.02
	g.tick(1.0)
	eq(g.current_mult(), 1, "decay breaks combo")

func test_endless_waves_and_end() -> void:
	var g := _game()
	g.start_endless()
	ok(g.remaining_time() > 1e6, "untimed")
	g.score = 1499
	eq(g.endless_wave(), 1, "wave 1")
	g.score = 2500
	eq(g.endless_wave(), 2, "wave 2 at 2000+")
	while g.lives > 0: g.on_forbidden_hit()
	var ended := []
	g.level_ended.connect(func(r): ended.append(r))
	g.check_end_conditions()
	eq(ended.size(), 1, "endless ends at 0 lives")
	ok(not ended[0].won, "endless never 'wins'")
```

- [ ] **Step 2: Verify failure.**
- [ ] **Step 3: Implement** `game.gd` per interface. Tick order: freeze gate → elapsed advance → meter decay (empty ⇒ combo break) → double expiry → end conditions. `_finish(won)` emits result once, guards `_running`.
- [ ] **Step 4: Green** — if a spec-backed assertion conflicts with implementation, fix implementation; deviations must be noted in commit body.
- [ ] **Step 5: Commit** — `git add src/autoload/game.gd tests/test_game_rules.gd && git commit -m "feat: authoritative run state machine with combos, powerups and endings"`

---

### Task 12: Board, holes, mallet, hit detection — playable loop

**Files:** Create `src/logic/hit_test.gd`, `src/game/board.gd/.tscn`, `hole.gd/.tscn`, `mallet.gd/.tscn`, `fx_layer.gd`; Test `tests/test_hit_test.gd`, `tests/smoke_board.gd`

**Interfaces:**
- Consumes: SpawnDirector (interval source = bound `cfg.interval_at`), Rat scene, painters, Palettes, Game, AudioManager
- Produces:
  - `class_name HitTest`: `static pick(pos:Vector2, radius:float, candidates:Array)->int` — candidates `[{"pos":Vector2,...}]`, nearest-within-radius wins, −1 miss
  - `Board.tscn` (Node2D): `setup(level_cfg, interval_fn)` builds themed backdrop, hole grid (spacing Vector2(190,165), z_index=row), mallet, FxLayer, configures director; `_process` ticks director + `Game.tick(delta)`; `_unhandled_input` LMB press ⇒ swing at mouse global pos; signals relay `rat_bonked(id)`, `rat_escaped(id)`, `forbidden_hit(id)`, `whiffed`
  - `Hole.tscn` (Node2D): draws via HolePainter (+front-rim sibling drawn over rat z-order); owns ≤1 Rat; `occupied()->bool`, `spawn_rat(id, speed_scale)`, `try_strike()->String` ∈ {"bonked","staggered","forbidden","miss"} (routes rat.strike(); forbidden ids return "forbidden" and emit `forbidden_struck`), `rat_head_global_pos()->Vector2` (pos + Vector2(0,-40)), `rat_id()->String`
  - `Mallet.tscn` (Node2D): lerp-follow pointer in `_process`; `swing_at(global_pos)` plays rotation tween −70°→0° over ~90 ms; painter-driven visuals
  - `FxLayer` (Node2D): `impact(pos, strong)` star-burst CPUParticles2D one-shot pool; `shake(amount)` offsets parent respecting `Settings.shake_enabled`; haptic hook `Input.vibrate_handheld(30)` guarded by `OS.get_name()=="Android"` on strong impacts

- [ ] **Step 1: Failing pick tests** `tests/test_hit_test.gd`

```gdscript
extends TestCase

func test_pick_within_radius() -> void:
	var cands := [{"pos": Vector2(100, 100)}, {"pos": Vector2(300, 100)}]
	eq(HitTest.pick(Vector2(120, 100), 40.0, cands), 0, "hits first")
	eq(HitTest.pick(Vector2(280, 130), 40.0, cands), 1, "hits second")
	eq(HitTest.pick(Vector2(200, 100), 40.0, cands), -1, "gap = miss")
	eq(HitTest.pick(Vector2(500, 500), 40.0, cands), -1, "far = miss")

func test_nearest_wins_on_overlap() -> void:
	var cands := [{"pos": Vector2(100, 100)}, {"pos": Vector2(130, 100)}]
	eq(HitTest.pick(Vector2(115, 100), 40.0, cands), 0, "closest wins")
```

- [ ] **Step 2: Implement HitTest** (distance_squared_to vs radius², strict nearest tracking).
- [ ] **Step 3: Implement Hole, Board, Mallet, FxLayer** per interfaces. Board swing flow: gather occupied candidates → HitTest.pick(radius 78) → route result ("miss"⇒whiff SFX + Game.on_whiff; "bonked"⇒bonk/bonk_heavy SFX by id + impact FX + haptic; "staggered"⇒bonk_heavy only; "forbidden"⇒yowl + flash FX + forbidden_hit signal). Escaped rats relay to Game via Board signals wired by the GameScreen in T13.
- [ ] **Step 4: Headless smoke** `tests/smoke_board.gd`

```gdscript
extends TestCase

func test_board_builds_and_director_runs_headless() -> void:
	Game.test_mode = true
	Game.start_level(load("res://src/data/levels/level_01.tres"))
	var board: Node2D = load("res://src/game/board.tscn").instantiate()
	root.add_child(board)   # SceneTree script: `root` available
	board.setup(Game.cfg, Game.cfg.interval_at)
	for i in range(120):    # ~2 simulated seconds of frames
		board._process(1.0 / 60.0)
	ok(board.get_child_count() > 2, "board populated children")
	var spawned := 0
	for h in board._holes:
		if h.occupied(): spawned += 1
		h.try_strike()      # must not crash regardless of occupancy
	ok(Game.score >= 0, "no crash during forced strikes")
	Game._running = false
	board.queue_free()

func test_hit_test_nearest_and_miss() -> void:
	# duplicate safety net independent of ordering above
	var cands := [{"pos": Vector2.ZERO}]
	eq(HitTest.pick(Vector2(10, 0), 50.0, cands), 0, "inside")
	eq(HitTest.pick(Vector2(90, 0), 50.0, cands), -1, "outside")
```

Note: smoke touches autoload `Game` directly — under `--script` runner autoloads are NOT auto-instanced, so `tests/run.gd` must be extended in this task: before running test modules whose filename starts with `smoke_`, instantiate required autoload scripts and add them named to root:

```gdscript
# inside run.gd _initialize, before discovery loop:
var autoloads := {
	"Settings": "res://src/autoload/settings.gd",
	"SaveManager": "res://src/autoload/save_manager.gd",
	"AudioManager": "res://src/autoload/audio_manager.gd",
	"Game": "res://src/autoload/game.gd",
}
for k in autoloads:
	if not root.has_node(k):
		var n: Node = load(autoloads[k]).new()
		n.name = k
		root.add_child(n)
```

- [ ] **Step 5: Green + manual sanity** — `make run` boots Splash; temporarily point main scene at board harness later (T13 wires real screens; skip if inconvenient).
- [ ] **Step 6: Commit** — `git add src/logic/hit_test.gd src/game tests/test_hit_test.gd tests/smoke_board.gd tests/run.gd && git commit -m "feat: playable board loop with mallet swings, holes and spawn direction"`

---

### Task 13: SceneRouter, HUD, pause, and all menu screens

**Files:** Rewrite `src/autoload/scene_router.gd`; Create `src/screens/{main_menu,zone_map,level_select,results,settings_screen}.gd/.tscn`, `src/game/game_screen.gd/.tscn` (owns Board+HUD), `src/game/hud.gd/.tscn`, `src/game/pause_overlay.gd/.tscn`; Modify splash to route; Test `tests/smoke_screens.gd`

**Interfaces:**
- Consumes: Game signals, SaveManager snapshots, Progression rules, Palettes/BackdropPainter
- Produces:
  - `SceneRouter.goto(path:String)`, `back()` — full-rect ColorRect fade (0.25 s out/in) on a persistent CanvasLayer; nav stack for back
  - Screen flow: Splash →(tap)→ MainMenu {Play→ZoneMap, Endless→GameScreen(endless) [visible iff Progression.endless_unlocked], Settings, Quit [hidden on web/android via `OS.has_feature("web")` / `"android"`]} ; ZoneMap → LevelSelect(zone) → GameScreen(level_id); GameScreen → Results(result); Results buttons Retry/Next(`Progression.next_level_id`)/Map
  - `LevelSelect`: 15 tiles in zone groups; stars (★ drawn or unicode) per level from SaveManager; locked tiles dimmed + lock glyph via `Progression.is_unlocked`
  - `HUD.tscn` (CanvasLayer): top-left score Label (tween-count up on score_changed), top-right time bar (time_left_changed), lives hearts row (lives_changed), combo meter bar bottom (combo_changed), floating "+N" popups at last impact position (subscribed from Board.rat_bonked with points payload), powerup chips w/ countdown (powerup_started); Pause button top-center → PauseOverlay (get_tree().paused=true, PROCESS_MODE_WHEN_PAUSED overlay): Resume/Restart/Quit-to-map
  - `Results` reads final `Game.level_ended` payload: star reveal stagger animation + SFX star_fanfare/win/fail, best-score line ("NEW BEST!" when beaten)
  - First-launch routing: if `SaveManager.is_tutorial_seen()` false ⇒ MainMenu Play routes through Tutorial first (T14 hook)

- [ ] **Step 1: Implement SceneRouter** (fade layer, deferred `change_scene_to_file`, tiny stack).
- [ ] **Step 2: Implement GameScreen** wiring Board ⇄ Game ⇄ HUD: connect board signals to game methods (`rat_bonked→on_rat_bonked` capturing returned points for popup FX, `forbidden_hit→on_forbidden_hit`, `escaped→on_rat_escaped`, `whiffed→on_whiff`), game signals to HUD, `level_ended` → router to Results after 1 s beat. Esc key toggles pause. Endless mode passes wave-accelerated interval callable `(p)->cfg.interval_at(p)/wave_speed` where `wave_speed = 1.0 + 0.12*(Game.endless_wave()-1)`.
- [ ] **Step 3: Implement the five screens + HUD + PauseOverlay** as Control scenes using Theme default font, big chunky Labels, Buttons with hover scale tweens; all colors from Palettes.
- [ ] **Step 4: Wire Splash** tap → SceneRouter.goto main_menu.
- [ ] **Step 5: Smoke tests** `tests/smoke_screens.gd`

```gdscript
extends TestCase

const SCREENS := [
	"res://src/screens/splash.tscn",
	"res://src/screens/main_menu.tscn",
	"res://src/screens/zone_map.tscn",
	"res://src/screens/level_select.tscn",
	"res://src/screens/results.tscn",
	"res://src/screens/settings_screen.tscn",
	"res://src/game/game_screen.tscn",
	"res://src/game/hud.tscn",
]

func test_every_screen_instantiates_clean() -> void:
	for p in SCREENS:
		var ps: PackedScene = load(p)
		ok(ps != null, "exists %s" % p)
		if ps == null: continue
		var n: Node = ps.instantiate()
		root.add_child(n)   # _ready runs; autoloads present via run.gd bootstrap (T12)
		ok(is_instance_valid(n), "boots %s" % p)
		n.queue_free()

func test_level_select_reflects_progression() -> void:
	var ls: Node = load("res://src/screens/level_select.tscn").instantiate()
	ls.zone_filter = 1      # exported var consumed by its build step
	root.add_child(ls)
	ok(ls.tile_count() == 5, "zone1 shows five tiles")
	ls.queue_free()
```

(LevelSelect must expose `zone_filter:int` export and `tile_count()->int` for this test.)

- [ ] **Step 6: Green + manual run pass** (`make run`: menu→map→select→play a level end-to-end).
- [ ] **Step 7: Commit** — `git add -A && git commit -m "feat: full screen flow, HUD and pause with scene routing"`

---

### Task 14: Tutorial overlay

**Files:** Create `src/screens/tutorial.gd/.tscn`; Modify MainMenu Play routing

**Interfaces:**
- Produces: scripted ~20 s interactive overlay reusing Board: Phase 1 "BONK 3 rats" (norm-only weights override, infinite-ish time, no forbidden chars); Phase 2 "Whiskers appears — DON'T bonk!" (single whiskers spawn; success = let it sink or timeout 4 s; fail = bonked ⇒ gentle retry of phase); completion ⇒ `SaveManager.mark_tutorial_seen()` → ZoneMap. Skippable via Skip button always visible.

- [ ] **Step 1: Implement** Tutorial screen: own Board instance, custom director weights `{norm:100}` then `{whiskers:100}`, banner labels + pointing arrow draw, phase machine, skip button.
- [ ] **Step 2: Hook routing** — MainMenu Play: `if not SaveManager.is_tutorial_seen(): goto tutorial else zone_map`.
- [ ] **Step 3: Verify manually** (`rm user://save.cfg` path under app_userdata to reset flag; run flow twice — second launch skips). Add smoke case instantiating tutorial.tscn clean.
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: interactive first-launch tutorial"`

---

### Task 15: Endless mode + Top-10 leaderboard UI

**Files:** Create `src/screens/endless_results.gd/.tscn` (or extend results with mode branch); Modify MainMenu endless gating; Test extension

**Interfaces:**
- Consumes: Game endless mode, SaveManager.submit_endless/top_ten, Progression.endless_unlocked
- Produces: Endless entry point gated (locked tile + tooltip "Clear Basement"); on death → name-entry panel (LineEdit max 8 chars, default "RAT", virtual keyboard works touch/web) → submit rank display ("#3 IN TOP 10!") → leaderboard list view (top_ten render, medal colors for ranks 1–3)

- [ ] **Step 1: Implement** results-mode branch + leaderboard view + gating in menus.
- [ ] **Step 2: Tests**

```gdscript
extends TestCase

func test_submit_returns_rank_and_persists() -> void:
	SaveManager.reset_all()
	for s in [100, 200, 300]: SaveManager.submit_endless("AAA", s)
	eq(SaveManager.submit_endless("ZZZ", 250), 3, "250 is rank 3")
	eq(SaveManager.top_ten().size(), 4, "board grew")
	eq(SaveManager.submit_endless("LOW", 1), 0, "unplaced returns 0")

func test_endless_gate_in_ui_state() -> void:
	ok(Progression.endless_unlocked({6: 1, 7: 1, 8: 1, 9: 1, 10: 1}), "gate open state")
	ok(not Progression.endless_unlocked({}), "gate closed fresh")
```

- [ ] **Step 3: Green** + manual endless run to name entry.
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: endless mode with local top-10 leaderboard"`

---

### Task 16: Juice & polish pass

**Files:** Modify `fx_layer.gd`, `hud.gd`, `board.gd`, painters as needed; Create `assets/audio` additions only if trivially synthesized

**Interfaces:** no new public APIs; observable polish:
- Squash/stretch already tween-driven; ADD: hole dirt puff particles on rat rise; golden sparkle trail; confetti burst on 3-star results; freeze overlay (blue tint + clock vignette) while `_freeze_left>0`; double-points gold tint on score label; hit-stop micro-pause (60 ms Engine.time_scale=0.05) on tank final blow; screen shake amounts: normal bonk 2 px, forbidden 6 px, boom 10 px (respect toggle)
- Combo callouts at ×2/×4/×8 thresholds ("NICE!", "GREAT!", "UNSTOPPABLE!") with combo_N chime
- Android haptics: light 20 ms on any bonk, strong pattern on forbidden (already hooked in FxLayer — verify paths)

- [ ] **Step 1: Implement each effect above** (small, isolated commits allowed within task).
- [ ] **Step 2: Manual juice review** — play L1/L7/L15 + endless; confirm no effect breaks headless smoke tests (run `make test`).
- [ ] **Step 3: Balance sanity** — play-test L1 (should 3-star comfortably for a competent player), L15 (challenging), adjust ONLY `.tres` quotas via table + regenerate if wildly off; note changes in commit body.
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: juice pass — particles, shake, hit-stop, combo callouts, tints"`

---

### Task 17: Export presets — Linux, Web, Android

**Files:** Create `export_presets.cfg`, `export/android/debug.keystore` (generated locally, gitignored), `icon.svg` finalization

**Interfaces:**
- Presets (names exactly matching Makefile): `Linux` (x86_64), `Web` (thread support OFF, progressive fetch OFF), `Android` (arm64-v8a only, landscape, package `dev.parasaran.bonktherat`, debug keystore at project-local `export/android/debug.keystore` with store/user passwords recorded in preset debug fields — file itself gitignored)

- [ ] **Step 1: Generate project-local debug keystore** (self-contained, avoids touching home-dir config):

```bash
mkdir -p export/android && keytool -genkeypair -v \
  -keystore export/android/debug.keystore -alias androiddebugkey \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=BONK THE RAT Debug,O=BONK,C=DE"
```

Confirm `export/android/` is gitignored (extend `.gitignore` with `export/` — already covered).

- [ ] **Step 2: Write export_presets.cfg** with the three presets; Web preset extra: `variant/thread_support=false`; Android preset: `architectures/arm64-v8a=true`, keystore paths relative `res://export/android/debug.keystore`.
- [ ] **Step 3: Build all three** — `make export-linux export-web export-android`.
Expected: `export/linux/bonk-the-rat.x86_64` executable; `export/web/index.html + .wasm + .pck`; `export/android/bonk-the-rat.apk`. Fix preset/config errors until all three succeed headlessly.
- [ ] **Step 4: Smoke each artifact** — Linux binary `timeout 8 ./export/linux/bonk-the-rat.x86_64 --quit-after 120` exits clean; web files exist non-empty; apk unzips containing `lib/arm64-v8a/libgodot_android.so` + assets pck (`unzip -l`).
- [ ] **Step 5: Commit** — `git add export_presets.cfg .gitignore icon.svg && git commit -m "build: export presets for linux, web and android"`

---

### Task 18: Documentation set + final verification sweep

**Files:** Create `README.md`, `AGENTS.md`, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`, `docs/CONTENT_GUIDE.md`, `docs/BUILD_EXPORT.md`, complete `docs/ART_AUDIO.md`

**Interfaces:** docs are deliverables; accuracy verified against real code (commands actually run, paths actually existing).

- [ ] **Step 1: README.md** — pitch paragraph, screenshot placeholders, quickstart (clone → open in Godot 4.6 or `make run`), controls (click/tap = bonk, esc = pause), platform matrix, link table to docs/.
- [ ] **Step 2: AGENTS.md** — repo map tree with one-line responsibilities; command table (run/test/audio/levels/export-*); conventions (signals-over-direct-calls, pure logic in src/logic, painters draw-only, .tres levels generated then hand-tunable); guardrails (no plugins, no push, docs-in-same-commit); recipes: "add a level" (edit tools/generate_levels.gd table → make levels → tune tres), "add a rat type" (RatTypes entry + RatPainter variant + optional weight in levels), "add an sfx" (generate_audio.gd recipe + regenerate), "add a screen" (screens/*.tscn + SceneRouter goto).
- [ ] **Step 3: docs/GAME_DESIGN.md** — formalize spec §3 (roster, scoring, zones, endless, screens).
- [ ] **Step 4: docs/ARCHITECTURE.md** — autoload contracts table (copy from spec §4.2 verbatim), signal map, data-flow diagram (ASCII), scene inventory, test harness explanation.
- [ ] **Step 5: docs/CONTENT_GUIDE.md** — tuning tables explained, quota math guidance, difficulty levers list.
- [ ] **Step 6: docs/BUILD_EXPORT.md** — prereqs (Godot 4.6.1, JDK 17+/25, Android SDK cmdline-tools + build-tools, export templates 4.6.1.stable), per-target steps, web hosting note (any static server; no COOP/COEP needed since threads off), keystore regeneration instructions.
- [ ] **Step 7: Complete docs/ART_AUDIO.md** — painter architecture, palette discipline, Synth DSP reference, music composition format, regen commands.
- [ ] **Step 8: Final verification sweep (all must pass)**:

```bash
make test                      # green, zero FAIL
godot --headless --import --path .   # no errors
make export-linux export-web export-android   # all three artifacts
timeout 8 ./export/linux/bonk-the-rat.x86_64 --quit-after 120
git log --oneline              # conventional history, no secrets staged
git status                     # clean
```

- [ ] **Step 9: Commit** — `git add -A && git commit -m "docs: full agent-onboarding documentation set"`

---

## Self-review notes (completed during planning)

- Spec coverage: roster/scoring/combo/lives (T2,T11), zones+stars+unlock (T3,T4), endless+top10 (T15), tutorial (T14), settings (T7), high scores (T6,T13), juice+haptics (T16), audio pipeline (T8,T9), art system (T10), persistence+corruption (T6), exports linux/web/android (T17), docs set (T18), testing strategy (T1 harness + every task TDD/smoke).
- Type consistency: interfaces cross-referenced (Scoring/Progression/RatTypes/SpawnDirector/SaveStore/Game/HitTest signatures used identically downstream).
- Known simplification vs spec §4.5: Rat FSM tests are synchronous by design; tween timing covered indirectly by board smoke (documented deviation, spec §5.2 allows logic-focused testing).

