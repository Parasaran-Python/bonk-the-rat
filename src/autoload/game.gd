extends Node
## Run-state singleton managing score, combos, powerups, timer and win/loss rules.

signal score_changed(total: int)
signal combo_changed(mult: int, fill: float)
signal lives_changed(lives: int)
signal time_left_changed(sec: float)
signal powerup_started(kind: String, dur: float)
signal level_ended(result: Dictionary)

const START_LIVES := 3
const FREEZE_SECONDS := 5.0
const DOUBLE_SECONDS := 8.0

var score: int = 0
var lives: int = START_LIVES
var combo_hits: int = 0
var meter: float = 0.0
var double_active: bool = false
var best_combo: int = 0
var mode: String = "campaign"
var cfg: LevelConfig = null
var test_mode: bool = false

var _running: bool = false
var _time_elapsed: float = 0.0
var _freeze_left: float = 0.0
var _double_left: float = 0.0

func start_level(level_cfg: LevelConfig) -> void:
	mode = "campaign"
	cfg = level_cfg
	score = 0
	lives = START_LIVES
	combo_hits = 0
	meter = 0.0
	double_active = false
	best_combo = 0
	_time_elapsed = 0.0
	_freeze_left = 0.0
	_double_left = 0.0
	_running = true

	score_changed.emit(score)
	lives_changed.emit(lives)
	combo_changed.emit(current_mult(), meter)
	time_left_changed.emit(remaining_time())

func start_endless() -> void:
	mode = "endless"
	if ResourceLoader.exists("res://src/data/levels/endless.tres"):
		cfg = load("res://src/data/levels/endless.tres")
	else:
		cfg = null
	score = 0
	lives = START_LIVES
	combo_hits = 0
	meter = 0.0
	double_active = false
	best_combo = 0
	_time_elapsed = 0.0
	_freeze_left = 0.0
	_double_left = 0.0
	_running = true

	score_changed.emit(score)
	lives_changed.emit(lives)
	combo_changed.emit(current_mult(), meter)
	time_left_changed.emit(remaining_time())

func active() -> bool:
	return _running

func remaining_time() -> float:
	if mode == "endless" or cfg == null:
		return 9999999.0
	return maxf(0.0, cfg.duration_s - _time_elapsed)

func endless_wave() -> int:
	return 1 + int(score / 2000)

func current_mult() -> int:
	return Scoring.multiplier_for(combo_hits)

func trigger_powerup(kind: String, dur: float = -1.0) -> void:
	if not _running:
		return
	if kind == "freeze":
		var d := dur if dur > 0.0 else FREEZE_SECONDS
		_freeze_left = d
		powerup_started.emit("freeze", d)
	elif kind == "double" or kind == "star":
		var d := dur if dur > 0.0 else DOUBLE_SECONDS
		_double_left = d
		double_active = true
		powerup_started.emit("double", d)

func on_rat_bonked(rat_id: String) -> int:
	if not _running:
		return 0

	if RatTypes.is_forbidden(rat_id):
		on_forbidden_hit()
		return 0

	var info := RatTypes.get_type(rat_id)
	var base_pts: int = int(info.get("points", 100))
	var p_up: String = str(info.get("powerup", ""))

	if p_up != "":
		trigger_powerup(p_up)

	combo_hits += 1
	best_combo = maxi(best_combo, combo_hits)
	var awarded := Scoring.points_for(base_pts, combo_hits, double_active)
	score += awarded
	meter = Scoring.meter_after_hit(meter)

	score_changed.emit(score)
	combo_changed.emit(current_mult(), meter)
	return awarded

func on_rat_escaped(id: String) -> void:
	if not _running:
		return
	if RatTypes.is_forbidden(id):
		return
	combo_hits = 0
	meter = 0.0
	combo_changed.emit(current_mult(), meter)

func on_forbidden_hit() -> void:
	if not _running:
		return
	lives -= 1
	combo_hits = 0
	meter = 0.0
	lives_changed.emit(lives)
	combo_changed.emit(current_mult(), meter)
	check_end_conditions()

func on_whiff() -> void:
	if not _running:
		return
	meter = Scoring.meter_after_whiff(meter)
	if meter <= 0.0:
		combo_hits = 0
	combo_changed.emit(current_mult(), meter)

func tick(delta: float) -> void:
	if not _running:
		return

	if _freeze_left > 0.0:
		_freeze_left = maxf(0.0, _freeze_left - delta)
	else:
		if mode == "campaign":
			_time_elapsed += delta
			time_left_changed.emit(remaining_time())

	if _double_left > 0.0:
		_double_left = maxf(0.0, _double_left - delta)
		if _double_left <= 0.0:
			double_active = false

	if combo_hits > 0:
		meter = Scoring.meter_after_time(meter, delta)
		if meter <= 0.0:
			combo_hits = 0
			meter = 0.0
		combo_changed.emit(current_mult(), meter)

	check_end_conditions()

func check_end_conditions() -> void:
	if not _running:
		return
	if lives <= 0:
		_finish(false)
	elif mode == "campaign" and remaining_time() <= 0.0:
		var stars := 0
		if cfg != null:
			stars = Scoring.stars_for_score(score, cfg.quota_star1, cfg.quota_star2, cfg.quota_star3)
		_finish(stars >= 1)

func _finish(won: bool) -> void:
	if not _running:
		return
	_running = false
	var stars := 0
	if won and mode == "campaign" and cfg != null:
		stars = Scoring.stars_for_score(score, cfg.quota_star1, cfg.quota_star2, cfg.quota_star3)

	var res := {
		"mode": mode,
		"won": won,
		"score": score,
		"stars": stars,
		"best_combo": best_combo,
	}

	if not test_mode:
		if mode == "campaign" and cfg != null and has_node("/root/SaveManager"):
			get_node("/root/SaveManager").set_result(cfg.level_id, score, stars)
		if has_node("/root/AudioManager"):
			var am: Node = get_node("/root/AudioManager")
			if won:
				am.play_sfx("level_win")
			else:
				am.play_sfx("level_fail")

	level_ended.emit(res)
