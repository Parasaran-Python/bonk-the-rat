class_name Progression
extends RefCounted

const LEVEL_COUNT := 15
const ENDLESS_GATE_LEVEL := 10

static func is_unlocked(level_id: int, stars: Dictionary) -> bool:
	if level_id <= 1:
		return true
	return int(stars.get(level_id - 1, 0)) >= 1

static func endless_unlocked(stars: Dictionary) -> bool:
	for id: int in range(6, ENDLESS_GATE_LEVEL + 1):
		if int(stars.get(id, 0)) < 1:
			return false
	return true

static func total_stars(stars: Dictionary) -> int:
	var total := 0
	for id: int in range(1, LEVEL_COUNT + 1):
		total += int(stars.get(id, 0))
	return total

static func next_level_id(id: int) -> int:
	return id + 1 if id < LEVEL_COUNT else -1

static func zone_of(id: int) -> int:
	return int(ceil(id / 5.0))
