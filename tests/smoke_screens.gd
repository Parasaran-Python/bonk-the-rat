extends TestCase

const SCREENS := [
	"res://src/screens/splash.tscn",
	"res://src/screens/main_menu.tscn",
	"res://src/screens/zone_map.tscn",
	"res://src/screens/level_select.tscn",
	"res://src/screens/results.tscn",
	"res://src/screens/settings_screen.tscn",
	"res://src/game/game_screen.tscn",
	"res://src/game/hud.tscn",
]

func test_every_screen_instantiates_clean() -> void:
	for p in SCREENS:
		var ps: PackedScene = load(p)
		ok(ps != null, "exists %s" % p)
		if ps == null:
			continue
		var n: Node = ps.instantiate()
		if root != null:
			root.add_child(n)
		ok(is_instance_valid(n), "boots %s" % p)
		n.queue_free()

func test_level_select_reflects_progression() -> void:
	var ls: Node = load("res://src/screens/level_select.tscn").instantiate()
	ls.zone_filter = 1
	if root != null:
		root.add_child(ls)
	eq(ls.tile_count(), 5, "zone1 shows five tiles")
	ls.queue_free()
