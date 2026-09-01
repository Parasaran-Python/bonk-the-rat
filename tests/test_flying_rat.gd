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
