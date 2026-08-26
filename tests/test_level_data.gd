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
