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

func test_endless_resource() -> void:
	var e: LevelConfig = load("res://src/data/levels/endless.tres")
	ok(e != null and e.level_id == 0, "endless resource present")

func test_level_progression_grid_dimensions() -> void:
	var l1 := _load(1)
	eq(l1.grid_columns, 3, "l1 columns == 3")
	eq(l1.grid_rows, 2, "l1 rows == 2")
	eq(l1.hole_count(), 6, "l1 hole count == 6")
	eq(l1.max_concurrent, 1, "l1 max concurrent == 1")
	ok(is_equal_approx(l1.spawn_interval_start, 1.40), "l1 interval start 1.40")
	ok(is_equal_approx(l1.spawn_interval_end, 0.95), "l1 interval end 0.95")

	var l5 := _load(5)
	eq(l5.grid_columns, 3, "l5 columns == 3")
	eq(l5.grid_rows, 3, "l5 rows == 3")
	eq(l5.hole_count(), 9, "l5 hole count == 9")

	var l10 := _load(10)
	eq(l10.grid_columns, 4, "l10 columns == 4")
	eq(l10.grid_rows, 3, "l10 rows == 3")
	eq(l10.hole_count(), 12, "l10 hole count == 12")

	var l14 := _load(14)
	eq(l14.grid_columns, 5, "l14 columns == 5")
	eq(l14.grid_rows, 3, "l14 rows == 3")
	eq(l14.hole_count(), 15, "l14 hole count == 15")

	var l15 := _load(15)
	eq(l15.grid_columns, 5, "l15 columns == 5")
	eq(l15.grid_rows, 3, "l15 rows == 3")
	eq(l15.hole_count(), 15, "l15 hole count == 15")
	eq(l15.max_concurrent, 7, "l15 max concurrent == 7")
	ok(is_equal_approx(l15.spawn_interval_start, 0.65), "l15 interval start 0.65")
	ok(is_equal_approx(l15.spawn_interval_end, 0.30), "l15 interval end 0.30")

	var end := load("res://src/data/levels/endless.tres") as LevelConfig
	eq(end.grid_columns, 5, "endless columns == 5")
	eq(end.grid_rows, 3, "endless rows == 3")
	eq(end.hole_count(), 15, "endless hole count == 15")
	eq(end.max_concurrent, 4, "endless max concurrent == 4")
	ok(is_equal_approx(end.spawn_interval_start, 0.90), "endless interval start 0.90")
	ok(is_equal_approx(end.spawn_interval_end, 0.90), "endless interval end 0.90")



