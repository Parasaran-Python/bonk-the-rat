extends TestCase

const REQUIRED := ["bonk", "bonk_heavy", "squeak", "whiff", "yowl", "boom",
	"freeze_chime", "star_pickup", "combo_1", "combo_2", "combo_3", "combo_4", "combo_5",
	"star_fanfare", "ui_click", "ui_back", "level_win", "level_fail"]

func test_all_sfx_load_nonempty() -> void:
	for n in REQUIRED:
		var s: AudioStream = load("res://assets/audio/%s.wav" % n)
		ok(s != null and s.get_length() > 0.01, "loads non-empty %s" % n)

func test_buses_created() -> void:
	var am: Node = load("res://src/autoload/audio_manager.gd").new()
	am._make_buses()
	ok(AudioServer.get_bus_index("Music") != -1, "Music bus exists")
	ok(AudioServer.get_bus_index("SFX") != -1, "SFX bus exists")
