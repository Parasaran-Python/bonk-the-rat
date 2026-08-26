class_name HitTest
extends RefCounted
## Pure geometric nearest-neighbor hit testing.

static func pick(pos: Vector2, radius: float, candidates: Array) -> int:
	var best_idx := -1
	var best_dist_sq := radius * radius

	for i in range(candidates.size()):
		var cand: Variant = candidates[i]
		var c_pos := Vector2.ZERO
		if cand is Dictionary:
			c_pos = cand.get("pos", Vector2.ZERO)
		elif cand is Object and "pos" in cand:
			c_pos = cand.pos
		elif cand is Vector2:
			c_pos = cand
		elif cand is Node2D:
			c_pos = cand.global_position

		var dist_sq := pos.distance_squared_to(c_pos)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_idx = i

	return best_idx
