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
	eq(hit_res, "bonked", "strike returned bonked")
	ok(not frat.can_be_hit(), "cannot hit after bonk")
	frat.queue_free()

func test_flying_rat_sine_wave_motion() -> void:
	var frat: FlyingRat = load("res://src/game/flying_rat.tscn").instantiate()
	if root != null:
		root.add_child(frat)
	frat.launch(Vector2(0, 150), Vector2(1, 0), 200.0)
	eq(snapped(frat.position.y, 0.1), 150.0, "initial y position matches base_y")
	
	# t = PI / 8 => t * 4 = PI / 2 => sin(PI / 2) = 1 => Y = 150 + 28 = 178
	var delta_peak: float = (PI / 2.0) / 4.0
	frat.tick(delta_peak)
	eq(snapped(frat.position.y, 0.1), 178.0, "y reaches peak sine amplitude")
	
	# t = 3 * PI / 8 => t * 4 = 3 * PI / 2 => sin(3 * PI / 2) = -1 => Y = 150 - 28 = 122
	var delta_trough: float = (PI) / 4.0
	frat.tick(delta_trough)
	eq(snapped(frat.position.y, 0.1), 122.0, "y reaches trough sine amplitude")
	frat.queue_free()

func test_flying_rat_escape_bounds() -> void:
	var frat: FlyingRat = load("res://src/game/flying_rat.tscn").instantiate()
	if root != null:
		root.add_child(frat)
	var escaped_signal_emitted: Array[bool] = [false]
	frat.escaped.connect(func(_r): escaped_signal_emitted[0] = true)
	
	# Launch rightwards near right edge
	frat.launch(Vector2(1300, 160), Vector2(1, 0), 400.0)
	ok(frat.is_flying(), "rat is initially flying")
	
	frat.tick(1.0)
	ok(escaped_signal_emitted[0], "escaped signal emitted when leaving viewport")
	ok(not frat.is_flying(), "rat is no longer flying after escape")
	ok(not frat.can_be_hit(), "rat cannot be hit after escape")
	frat.queue_free()

func test_flying_rat_leftward_flight_and_escape() -> void:
	var frat: FlyingRat = load("res://src/game/flying_rat.tscn").instantiate()
	if root != null:
		root.add_child(frat)
	var escaped_emitted: Array[bool] = [false]
	frat.escaped.connect(func(_r): escaped_emitted[0] = true)
	
	# Launch leftwards from right side
	frat.launch(Vector2(-50, 160), Vector2(-1, 0), 400.0)
	frat.tick(1.0)
	ok(escaped_emitted[0], "escaped emitted when moving past left boundary")
	ok(not frat.is_flying(), "rat is no longer flying")
	frat.queue_free()

func test_flying_rat_bonk_signal_and_powerup() -> void:
	var frat: FlyingRat = load("res://src/game/flying_rat.tscn").instantiate()
	if root != null:
		root.add_child(frat)
	var bonked_data: Array = []
	frat.bonked.connect(func(pos, ptype): bonked_data.append([pos, ptype]))
	
	frat.launch(Vector2(300, 180), Vector2(1, 0), 300.0, "freeze")
	eq(frat.powerup_type, "freeze", "powerup type correctly assigned")
	eq(frat.z_index, 200, "z_index is 200 for high-altitude rendering")
	
	var res := frat.strike()
	eq(res, "bonked", "strike returned bonked")
	eq(bonked_data.size(), 1, "bonked signal was emitted once")
	eq(bonked_data[0][1], "freeze", "bonked signal emitted matching powerup_type")
	eq(frat.state, FlyingRat.State.BONKED, "state changed to BONKED")
	ok(not frat.can_be_hit(), "cannot hit after bonk")
	
	# Second strike should do nothing
	var second_res := frat.strike()
	eq(second_res, "", "second strike ignored")
	eq(bonked_data.size(), 1, "no second bonked signal")
	frat.queue_free()

func test_board_swings_and_hits_flying_rat() -> void:
	var board: Board = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg: LevelConfig = load("res://src/data/levels/level_04.tres")
	board.setup(cfg)
	var frat: FlyingRat = board.spawn_flying_rat_for_test(Vector2(640, 180))
	ok(frat != null, "flying rat spawned on board")
	board.swing_at(Vector2(640, 180))
	ok(not frat.can_be_hit(), "flying rat was hit by mallet swing")
	board.queue_free()

func test_board_flying_rat_awards_score_and_powerup() -> void:
	var board: Board = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg: LevelConfig = load("res://src/data/levels/level_04.tres")
	board.setup(cfg)
	Game.test_mode = true
	Game.start_level(cfg)
	var initial_score := Game.score
	var bonked_events: Array = []
	board.rat_bonked.connect(func(id, pts, pos): bonked_events.append([id, pts, pos]))
	var powerups_started: Array = []
	Game.powerup_started.connect(func(k, d): powerups_started.append([k, d]))
	
	var frat: FlyingRat = board.spawn_flying_rat_for_test(Vector2(600, 170), Vector2.RIGHT, 380.0, "freeze")
	board.swing_at(Vector2(600, 170))
	
	eq(Game.score, initial_score + 1000, "+1000 awarded to score")
	eq(bonked_events.size(), 1, "rat_bonked emitted once")
	eq(bonked_events[0][0], "flying", "rat_id is flying")
	eq(bonked_events[0][1], 1000, "points are 1000")
	eq(powerups_started.size(), 1, "powerup started emitted")
	eq(powerups_started[0][0], "freeze", "powerup kind is freeze")
	board.queue_free()

func test_board_flying_rat_miss_whiffs() -> void:
	var board: Board = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg: LevelConfig = load("res://src/data/levels/level_04.tres")
	board.setup(cfg)
	var frat: FlyingRat = board.spawn_flying_rat_for_test(Vector2(640, 180))
	var whiff_emitted: Array[bool] = [false]
	board.whiffed.connect(func(): whiff_emitted[0] = true)
	board.swing_at(Vector2(100, 50))
	ok(whiff_emitted[0], "whiffed signal emitted")
	ok(frat.can_be_hit(), "flying rat still targetable after whiff")
	board.queue_free()

func test_board_flying_rat_spawning_progression() -> void:
	var board: Board = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg1: LevelConfig = load("res://src/data/levels/level_01.tres")
	board.setup(cfg1)
	ok(not board.has_flying_rat(), "no flying rat in level 1")
	board.tick_flying_rat_spawner(50.0)
	ok(not board.has_flying_rat(), "level 1 does not spawn flying rat over time")
	
	var cfg4: LevelConfig = load("res://src/data/levels/level_04.tres")
	board.setup(cfg4)
	board.tick_flying_rat_spawner(cfg4.duration_s * 0.4)
	ok(board.has_flying_rat(), "level 4 spawned flying rat at milestone")
	board.queue_free()

