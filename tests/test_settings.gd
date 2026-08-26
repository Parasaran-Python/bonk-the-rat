extends TestCase

func test_defaults_and_persistence() -> void:
	var path := "user://test_settings_%d.cfg" % Time.get_ticks_msec()
	var s1: Node = load("res://src/autoload/settings.gd").new()
	s1.SETTINGS_PATH = path
	eq(s1.music_volume, 0.8, "music default")
	eq(s1.sfx_volume, 1.0, "sfx default")
	ok(s1.shake_enabled, "shake default")
	s1.set_music_volume(0.25)
	s1.set_shake_enabled(false)
	var s2: Node = load("res://src/autoload/settings.gd").new()
	s2.SETTINGS_PATH = path
	eq(s2.music_volume, 0.25, "volume persisted")
	ok(not s2.shake_enabled, "shake persisted")

func test_volume_clamps() -> void:
	var s: Node = load("res://src/autoload/settings.gd").new()
	s.SETTINGS_PATH = "user://test_settings_clamp.cfg"
	s.set_music_volume(5.0)
	eq(s.music_volume, 1.0, "clamped high")
	s.set_sfx_volume(-1.0)
	eq(s.sfx_volume, 0.0, "clamped low")
