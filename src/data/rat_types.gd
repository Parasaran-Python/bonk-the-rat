class_name RatTypes
extends RefCounted
## Static rat roster. Timings in seconds: rise / up / sink.

const TYPES := {
	"norm": {"points": 100, "hp": 1, "rise": 0.30, "up": 1.00, "sink": 0.22},
	"zoomer": {"points": 250, "hp": 1, "rise": 0.16, "up": 0.55, "sink": 0.12},
	"tank": {"points": 300, "hp": 2, "rise": 0.34, "up": 1.40, "sink": 0.20},
	"golden": {"points": 500, "hp": 1, "rise": 0.14, "up": 0.45, "sink": 0.10},
	"clock": {"points": 150, "hp": 1, "rise": 0.26, "up": 0.90, "sink": 0.18, "powerup": "freeze"},
	"star": {"points": 150, "hp": 1, "rise": 0.26, "up": 0.90, "sink": 0.18, "powerup": "double"},
	"whiskers": {"points": 0, "hp": 1, "rise": 0.36, "up": 1.10, "sink": 0.24, "forbidden": true},
	"boom": {"points": 0, "hp": 1, "rise": 0.30, "up": 2.20, "sink": 0.30, "forbidden": true},
}

static func ids() -> Array:
	return TYPES.keys()

static func get_type(id: String) -> Dictionary:
	return TYPES.get(id, {})

static func is_forbidden(id: String) -> bool:
	return bool(TYPES.get(id, {}).get("forbidden", false))
