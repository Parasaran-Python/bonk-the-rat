class_name MainMenu
extends Control
## Main menu hub allowing mode selection, settings configuration and tutorial access.

@onready var _play_btn: Button = $VBox/PlayBtn
@onready var _endless_btn: Button = $VBox/EndlessBtn
@onready var _settings_btn: Button = $VBox/SettingsBtn
@onready var _quit_btn: Button = $VBox/QuitBtn

func _ready() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_music("menu", true)

	if _play_btn != null:
		_play_btn.pressed.connect(_on_play_pressed)
	if _endless_btn != null:
		_endless_btn.pressed.connect(_on_endless_pressed)
		_update_endless_state()
	if _settings_btn != null:
		_settings_btn.pressed.connect(_on_settings_pressed)
	if _quit_btn != null:
		if OS.has_feature("web") or OS.has_feature("android"):
			_quit_btn.visible = false
		else:
			_quit_btn.pressed.connect(func(): get_tree().quit(0))

func _update_endless_state() -> void:
	var unlocked := false
	if has_node("/root/SaveManager"):
		var sm: Node = get_node("/root/SaveManager")
		unlocked = Progression.endless_unlocked(sm.stars_snapshot())
	_endless_btn.disabled = not unlocked
	if not unlocked:
		_endless_btn.text = "ENDLESS (CLEAR ZONE 2)"
	else:
		_endless_btn.text = "ENDLESS MODE"

func _on_play_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")

	var tutorial_seen := true
	if has_node("/root/SaveManager"):
		tutorial_seen = get_node("/root/SaveManager").is_tutorial_seen()

	if not tutorial_seen and ResourceLoader.exists("res://src/screens/tutorial.tscn"):
		if has_node("/root/SceneRouter"):
			get_node("/root/SceneRouter").goto("res://src/screens/tutorial.tscn")
	else:
		if has_node("/root/SceneRouter"):
			get_node("/root/SceneRouter").goto("res://src/screens/zone_map.tscn")

func _on_endless_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"mode": "endless", "level_id": 0})

func _on_settings_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/settings_screen.tscn")
