class_name Palettes
extends RefCounted
## Color palettes and theme constants for the 3 game zones.

static func for_zone(theme: int) -> Dictionary:
	match theme:
		1:
			return {
				"bg": Color("e8c07a"),
				"bg_dark": Color("c29b53"),
				"accent": Color("d94f30"),
				"wood": Color("8b5a2b"),
				"dirt": Color("4a3319"),
				"shadow": Color(0.0, 0.0, 0.0, 0.27),
			}
		2:
			return {
				"bg": Color("4a5e75"),
				"bg_dark": Color("2d3b4e"),
				"accent": Color("63c5b5"),
				"wood": Color("5c4d3c"),
				"dirt": Color("222831"),
				"shadow": Color(0.0, 0.0, 0.0, 0.33),
			}
		3:
			return {
				"bg": Color("27343f"),
				"bg_dark": Color("141d24"),
				"accent": Color("ffd166"),
				"wood": Color("3d2e24"),
				"dirt": Color("18161a"),
				"shadow": Color(0.0, 0.0, 0.0, 0.40),
			}
		_:
			return for_zone(1)
