extends Control
## Boot screen. Displays game branding and routes to Main Menu on any input.

@onready var _prompt: Label = get_node_or_null("CenterContainer/VBox/Prompt")
var _started := false

func _ready() -> void:
	if not OS.has_feature("web") and has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		am.play_music("menu")

	if _prompt != null:
		if OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios"):
			_prompt.text = "TAP ANYWHERE TO START"
		else:
			_prompt.text = "CLICK OR PRESS ANY KEY TO START"

		var tw := create_tween().set_loops()
		tw.tween_property(_prompt, "modulate:a", 0.25, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(_prompt, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if _started:
		return

	var is_click: bool = (event is InputEventMouseButton) and event.is_pressed()
	var is_touch: bool = (event is InputEventScreenTouch) and event.is_pressed()
	var is_key: bool = (event is InputEventKey) and event.is_pressed() and not event.is_echo()
	var is_joy: bool = (event is InputEventJoypadButton) and event.is_pressed()

	if is_click or is_touch or is_key or is_joy:
		_start()

func _start() -> void:
	if _started:
		return
	_started = true
	set_process_input(false)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://src/screens/main_menu.tscn")

