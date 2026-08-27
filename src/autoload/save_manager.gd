extends Node
## Persistence singleton (Task 6): atomic tmp+rename writes; corrupt save ->
## rename to .bak, fall back to defaults and rewrite. Data rules in SaveStore.

signal save_changed

var SAVE_PATH := "user://save.cfg"

var _data: Dictionary = SaveStore.default_data()

func _ready() -> void:
	load_or_init()

func load_or_init() -> void:
	_data = SaveStore.default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var loaded := SaveStore.deserialize(FileAccess.get_file_as_string(SAVE_PATH))
	if loaded.is_empty():
		push_warning("SaveManager: corrupt save at %s - backing up and resetting." % SAVE_PATH)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".bak"))
		var err := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(SAVE_PATH),
			ProjectSettings.globalize_path(SAVE_PATH + ".bak"))
		if err != OK:
			push_warning("SaveManager: backup rename failed (%d)." % err)
		save_now()
	else:
		_data = loaded

func save_now() -> void:
	var tmp := SAVE_PATH + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: cannot open %s (%d)." % [tmp, FileAccess.get_open_error()])
		return
	f.store_string(SaveStore.serialize(_data))
	f.close()
	var err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(tmp),
		ProjectSettings.globalize_path(SAVE_PATH))
	if err != OK:
		push_warning("SaveManager: atomic rename failed (%d)." % err)

func get_stars(id: int) -> int:
	return int(_data["stars"].get(id, 0))

func get_best(id: int) -> int:
	return int(_data["best_scores"].get(id, 0))

func stars_snapshot() -> Dictionary:
	return _data["stars"].duplicate()

func set_result(id: int, score: int, stars: int) -> void:
	SaveStore.award_stars(_data, id, stars)
	SaveStore.record_best(_data, id, score)
	_persist()

func top_ten() -> Array:
	return (_data["endless_top10"] as Array).duplicate(true)

## Rank is 1-based; 0 = unplaced (strictly better entries already fill the board).
func submit_endless(entry_name: String, score: int) -> int:
	var better := 0
	for e: Dictionary in _data["endless_top10"]:
		if int(e["score"]) > score:
			better += 1
	SaveStore.submit_endless(_data, entry_name, score)
	_persist()
	return better + 1 if better < SaveStore.TOP_TEN_SIZE else 0

func is_tutorial_seen() -> bool:
	return bool(_data["tutorial_seen"])

func mark_tutorial_seen() -> void:
	SaveStore.mark_tutorial_seen(_data)
	_persist()

func reset_all() -> void:
	_data = SaveStore.default_data()
	_persist()

func _persist() -> void:
	save_now()
	save_changed.emit()
