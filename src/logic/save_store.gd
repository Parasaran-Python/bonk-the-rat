class_name SaveStore
extends RefCounted
## Pure save-data transforms (Task 6). File IO lives in SaveManager.

const SCHEMA_VERSION := 1
const TOP_TEN_SIZE := 10
const NAME_MAX_CHARS := 8

static func default_data() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"stars": {},
		"best_scores": {},
		"endless_top10": [],
		"tutorial_seen": false,
	}

static func serialize(data: Dictionary) -> String:
	return JSON.stringify(data)

## Returns an empty Dictionary on any error; callers test is_empty().
static func deserialize(text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = parsed
	if int(d.get("schema_version", -1)) != SCHEMA_VERSION:
		return {}
	for key in ["stars", "best_scores", "endless_top10", "tutorial_seen"]:
		if not d.has(key):
			return {}
	if typeof(d["endless_top10"]) != TYPE_ARRAY:
		return {}
	d["stars"] = _as_int_key_map(d["stars"])
	d["best_scores"] = _as_int_key_map(d["best_scores"])
	return d

static func _as_int_key_map(raw: Variant) -> Dictionary:
	var out := {}
	for k: Variant in raw:
		out[int(k)] = int(raw[k])
	return out

static func award_stars(data: Dictionary, id: int, stars: int) -> Dictionary:
	data["stars"][id] = maxi(int(data["stars"].get(id, 0)), stars)
	return data

static func record_best(data: Dictionary, id: int, score: int) -> Dictionary:
	data["best_scores"][id] = maxi(int(data["best_scores"].get(id, 0)), score)
	return data

static func submit_endless(data: Dictionary, entry_name: String, score: int) -> Dictionary:
	var entries: Array = data["endless_top10"]
	entries.append({
		"name": entry_name.substr(0, NAME_MAX_CHARS),
		"score": score,
		"date": Time.get_datetime_string_from_system(false, true),
	})
	entries.sort_custom(func(a: Variant, b: Variant) -> bool: return int(a.score) > int(b.score))
	if entries.size() > TOP_TEN_SIZE:
		entries.resize(TOP_TEN_SIZE)
	return data

static func mark_tutorial_seen(data: Dictionary) -> Dictionary:
	data["tutorial_seen"] = true
	return data
