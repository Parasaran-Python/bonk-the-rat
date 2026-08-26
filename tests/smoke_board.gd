extends TestCase

func test_board_builds_and_director_runs_headless() -> void:
	var game_node: Node = root.get_node("Game") if root != null and root.has_node("Game") else null
	if game_node != null:
		game_node.test_mode = true
		game_node.start_level(load("res://src/data/levels/level_01.tres"))
	var board: Node2D = load("res://src/game/board.tscn").instantiate()
	if root != null:
		root.add_child(board)
	var cfg: LevelConfig = load("res://src/data/levels/level_01.tres")
	board.setup(cfg, cfg.interval_at)
	for i in range(120): # ~2 simulated seconds of frames
		board._process(1.0 / 60.0)
	ok(board.get_child_count() > 2, "board populated children")
	var spawned := 0
	for h in board._holes:
		if h.occupied():
			spawned += 1
		h.try_strike() # must not crash regardless of occupancy
	if game_node != null:
		ok(game_node.score >= 0, "no crash during forced strikes")
		game_node._running = false
	board.queue_free()

func test_hit_test_nearest_and_miss() -> void:
	var cands := [{"pos": Vector2.ZERO}]
	eq(HitTest.pick(Vector2(10, 0), 50.0, cands), 0, "inside")
	eq(HitTest.pick(Vector2(90, 0), 50.0, cands), -1, "outside")
