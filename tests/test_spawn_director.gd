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
