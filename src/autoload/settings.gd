extends Node
## Settings singleton (Task 7): music/SFX volumes and screen-shake preference.
## Every setter clamps, persists immediately to a ConfigFile, then emits
## `changed`. Values lazy-load from SETTINGS_PATH, which stays overridable
## after construction (tests, hot-swap).

signal changed

var SETTINGS_PATH := "user://settings.cfg"

var music_volume := 0.8 :
	get:
		_ensure_loaded()
		return music_volume

var sfx_volume := 1.0 :
	get:
		_ensure_loaded()
		return sfx_volume

var shake_enabled := true :
	get:
		_ensure_loaded()
		return shake_enabled

var _loaded_path := ""

func _ready() -> void:
	_ensure_loaded()
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_persist()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_persist()

func set_shake_enabled(value: bool) -> void:
	shake_enabled = value
	_persist()

func _ensure_loaded() -> void:
	if _loaded_path == SETTINGS_PATH:
		return
	_loaded_path = SETTINGS_PATH
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	music_volume = clampf(float(cfg.get_value("audio", "music", 0.8)), 0.0, 1.0)
	sfx_volume = clampf(float(cfg.get_value("audio", "sfx", 1.0)), 0.0, 1.0)
	shake_enabled = bool(cfg.get_value("game", "shake", true))

func _persist() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("game", "shake", shake_enabled)
	var err := cfg.save(SETTINGS_PATH)
	if err != OK:
		push_warning("Settings: cannot write %s (%d)." % [SETTINGS_PATH, err])
		return
	changed.emit()
