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
	g.combo_hits = 2
	eq(g.on_rat_bonked("norm"), 200, "x2 kicks in")
	eq(g.score, 400, "total accumulates")
	g.combo_hits = 5
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
	eq(started.size(), 1, "freeze fired")
	eq(started[0][0], "freeze", "kind")
	eq(started[0][1], 5.0, "freeze 5s")
	var before: float = g.remaining_time()
	g.tick(2.0)
	eq(absf(g.remaining_time() - before) < 0.001, true, "time frozen")
	eq(g.on_rat_bonked("star"), 300, "star pays doubled at x1")
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
	var ended := []
	g.level_ended.connect(func(r): ended.append(r))
	while g.lives > 0: g.on_forbidden_hit()
	eq(ended.size(), 1, "endless ends at 0 lives")
	ok(not ended[0].won, "endless never 'wins'")
