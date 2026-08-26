class_name LevelSelect
extends Control
## Level selection grid presenting the 5 levels for the active zone.

@export var zone_filter: int = 1:
	set(v):
		zone_filter = v
		if is_inside_tree():
			_build_tiles()

var _back_btn: Button = null
var _title_lbl: Label = null
var _grid: HBoxContainer = null
var _tiles: Array[Button] = []

func _ready() -> void:
	_ensure_nodes()
	if is_inside_tree() and has_node("/root/SceneRouter"):
		var args: Dictionary = get_node("/root/SceneRouter").current_args
		if args.has("zone"):
			zone_filter = int(args["zone"])

	if _back_btn != null and not _back_btn.pressed.is_connected(_on_back_pressed):
		_back_btn.pressed.connect(_on_back_pressed)

	_build_tiles()

func _ensure_nodes() -> void:
	if _grid == null and has_node("GridContainer"):
		_grid = $GridContainer
	if _title_lbl == null and has_node("Header/Title"):
		_title_lbl = $Header/Title
	if _back_btn == null and has_node("Header/BackBtn"):
		_back_btn = $Header/BackBtn

func tile_count() -> int:
	if _tiles.is_empty():
		_build_tiles()
	return _tiles.size()

func _build_tiles() -> void:
	_ensure_nodes()
	if _title_lbl != null:
		var zone_names := ["", "ZONE 1: PANTRY", "ZONE 2: BASEMENT", "ZONE 3: KITCHEN"]
		var z_name: String = zone_names[zone_filter] if zone_filter < zone_names.size() else "ZONE %d" % zone_filter
		_title_lbl.text = z_name

	if _grid == null:
		if has_node("GridContainer"):
			_grid = $GridContainer
		else:
			return

	for c in _grid.get_children():
		c.queue_free()
	_tiles.clear()

	var stars_map := {}
	if is_inside_tree() and has_node("/root/SaveManager"):
		stars_map = get_node("/root/SaveManager").stars_snapshot()

	var start_id := (zone_filter - 1) * 5 + 1
	for i in range(start_id, start_id + 5):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(180, 220)
		btn.add_theme_font_size_override("font_size", 22)

		var unlocked := Progression.is_unlocked(i, stars_map)
		var stars := int(stars_map.get(i, 0))

		var star_str := ""
		for s in range(3):
			star_str += "⭐" if s < stars else "☆"

		if unlocked:
			btn.text = "LEVEL %d\n\n%s" % [i, star_str]
			var lvl_id := i
			btn.pressed.connect(func(): _start_level(lvl_id))
		else:
			btn.text = "LEVEL %d\n\n🔒" % i
			btn.disabled = true

		_grid.add_child(btn)
		_tiles.append(btn)

func _start_level(id: int) -> void:
	if is_inside_tree() and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if is_inside_tree() and has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"level_id": id, "mode": "campaign"})

func _on_back_pressed() -> void:
	if is_inside_tree() and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	if is_inside_tree() and has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/zone_map.tscn")
