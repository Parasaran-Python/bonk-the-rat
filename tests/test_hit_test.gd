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
