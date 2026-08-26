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
