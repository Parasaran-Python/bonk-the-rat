extends TestCase

func test_multiplier_steps() -> void:
	eq(Scoring.multiplier_for(0), 1, "no mult at 0")
	eq(Scoring.multiplier_for(2), 1, "no mult at 2")
	eq(Scoring.multiplier_for(3), 2, "x2 at 3")
	eq(Scoring.multiplier_for(5), 2, "x2 at 5")
	eq(Scoring.multiplier_for(6), 4, "x4 at 6")
	eq(Scoring.multiplier_for(8), 4, "x4 at 8")
	eq(Scoring.multiplier_for(9), 8, "x8 at 9")
	eq(Scoring.multiplier_for(50), 8, "caps at 8")

func test_points_with_combo_and_double() -> void:
	eq(Scoring.points_for(100, 0, false), 100, "base")
	eq(Scoring.points_for(100, 3, false), 200, "x2")
	eq(Scoring.points_for(250, 6, true), 2000, "250 x4 x2")
	eq(Scoring.points_for(500, 12, false), 4000, "golden capped x8")

func test_star_quotas() -> void:
	eq(Scoring.stars_for_score(0, 100, 200, 300), 0, "no stars")
	eq(Scoring.stars_for_score(100, 100, 200, 300), 1, "one star")
	eq(Scoring.stars_for_score(299, 100, 200, 300), 2, "two stars")
	eq(Scoring.stars_for_score(300, 100, 200, 300), 3, "three stars")

func test_meter_math_clamps() -> void:
	eq(Scoring.meter_after_hit(0.9), 1.0, "refill clamps high")
	eq(Scoring.meter_after_whiff(0.1), 0.0, "whiff clamps low")
	ok(absf(Scoring.meter_after_time(1.0, 5.0) - 0.6) < 0.001, "drains 0.08/s")
