class_name SpawnDirector
extends RefCounted

const HOLE_REUSE_MS := 400
const FALLBACK_INTERVAL := 1.0

var _rng: RandomNumberGenerator
var _holes := 0
var _weights: Dictionary = {}
var _max_concurrent := 0
var _cooldown := 0.0
var _last_spawn_ms: Dictionary = {}
var _interval_source := Callable()


func setup(seed_v: int = -1) -> void:
	_rng = RandomNumberGenerator.new()
	if seed_v < 0:
		_rng.randomize()
	else:
		_rng.seed = seed_v


func configure(holes: int, weights: Dictionary, max_concurrent: int) -> void:
	_holes = holes
	_weights = weights.duplicate()
	_max_concurrent = max_concurrent


func set_interval_source(fn: Callable) -> void:
	_interval_source = fn


func tick(delta_s: float, active_count: int, progress: float, now_ms: int) -> Dictionary:
	_cooldown -= delta_s
	if _cooldown > 0.0:
		return {}
	if active_count >= _max_concurrent:
		return {}
	var hole := _pick_fresh_hole(now_ms)
	if hole < 0:
		return {}
	var rat := _roll_rat()
	_last_spawn_ms[hole] = now_ms
	_cooldown = _next_interval(progress)
	return {"hole": hole, "rat": rat}


func _pick_fresh_hole(now_ms: int) -> int:
	var fresh: Array[int] = []
	for i in range(_holes):
		if _last_spawn_ms.has(i) and now_ms - int(_last_spawn_ms[i]) < HOLE_REUSE_MS:
			continue
		fresh.append(i)
	if fresh.is_empty():
		return -1
	return fresh[_rng.randi_range(0, fresh.size() - 1)]


func _roll_rat() -> String:
	var total := 0
	for w: int in _weights.values():
		total += w
	var roll := _rng.randi_range(1, total)
	var acc := 0
	for key: String in _weights:
		acc += _weights[key]
		if roll <= acc:
			return key
	return ""


func _next_interval(progress: float) -> float:
	if _interval_source.is_valid():
		return float(_interval_source.call(progress))
	return FALLBACK_INTERVAL
