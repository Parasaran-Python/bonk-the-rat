class_name Scoring
extends RefCounted

const MULT_STEPS := [3, 6, 9]
const MAX_MULT := 8
const REFILL := 0.25
const WHIFF_PENALTY := 0.15
const DRAIN_PER_SEC := 0.08

static func multiplier_for(consecutive_hits: int) -> int:
	var mult := 1
	for step: int in MULT_STEPS:
		if consecutive_hits >= step:
			mult *= 2
	return mult

static func points_for(base_points: int, consecutive_hits: int, double_active: bool) -> int:
	var doubled := 2 if double_active else 1
	return base_points * multiplier_for(consecutive_hits) * doubled

static func stars_for_score(score: int, q1: int, q2: int, q3: int) -> int:
	if score >= q3:
		return 3
	if score >= q2:
		return 2
	if score >= q1:
		return 1
	return 0

static func meter_after_hit(fill: float) -> float:
	return clampf(fill + REFILL, 0.0, 1.0)

static func meter_after_whiff(fill: float) -> float:
	return clampf(fill - WHIFF_PENALTY, 0.0, 1.0)

static func meter_after_time(fill: float, delta: float) -> float:
	return clampf(fill - DRAIN_PER_SEC * delta, 0.0, 1.0)
