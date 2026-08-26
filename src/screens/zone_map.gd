class_name ZoneMap
extends Control
## Zone selection screen showing the 3 themed chapters and aggregated star counts.

@onready var _back_btn: Button = $Header/BackBtn
@onready var _total_stars_lbl: Label = $Header/TotalStarsLabel
@onready var _zone1_btn: Button = $CardsContainer/Zone1Card
@onready var _zone2_btn: Button = $CardsContainer/Zone2Card
@onready var _zone3_btn: Button = $CardsContainer/Zone3Card

func _ready() -> void:
	if _back_btn != null:
		_back_btn.pressed.connect(_on_back_pressed)
	if _zone1_btn != null:
		_zone1_btn.pressed.connect(func(): _select_zone(1))
	if _zone2_btn != null:
		_zone2_btn.pressed.connect(func(): _select_zone(2))
	if _zone3_btn != null:
		_zone3_btn.pressed.connect(func(): _select_zone(3))

	_update_zones()

func _update_zones() -> void:
	var stars_map := {}
	if has_node("/root/SaveManager"):
		stars_map = get_node("/root/SaveManager").stars_snapshot()

	var total := Progression.total_stars(stars_map)
	if _total_stars_lbl != null:
		_total_stars_lbl.text = "⭐ %d / 45" % total

	# Zone 1 always unlocked
	var z1_stars := _count_zone_stars(1, stars_map)
	if _zone1_btn != null:
		_zone1_btn.text = "ZONE 1: PANTRY\n⭐ %d/15" % z1_stars

	# Zone 2 requires level 5 >= 1 star
	var z2_unlocked: bool = Progression.is_unlocked(6, stars_map)
	var z2_stars := _count_zone_stars(2, stars_map)
	if _zone2_btn != null:
		_zone2_btn.disabled = not z2_unlocked
		if z2_unlocked:
			_zone2_btn.text = "ZONE 2: BASEMENT\n⭐ %d/15" % z2_stars
		else:
			_zone2_btn.text = "ZONE 2: BASEMENT\n🔒 (Clear Level 5)"

	# Zone 3 requires level 10 >= 1 star
	var z3_unlocked: bool = Progression.is_unlocked(11, stars_map)
	var z3_stars := _count_zone_stars(3, stars_map)
	if _zone3_btn != null:
		_zone3_btn.disabled = not z3_unlocked
		if z3_unlocked:
			_zone3_btn.text = "ZONE 3: KITCHEN\n⭐ %d/15" % z3_stars
		else:
			_zone3_btn.text = "ZONE 3: KITCHEN\n🔒 (Clear Level 10)"

func _count_zone_stars(zone: int, stars_map: Dictionary) -> int:
	var c := 0
	var start_id := (zone - 1) * 5 + 1
	for i in range(start_id, start_id + 5):
		c += int(stars_map.get(i, 0))
	return c

func _select_zone(zone_id: int) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/level_select.tscn", {"zone": zone_id})

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/main_menu.tscn")
