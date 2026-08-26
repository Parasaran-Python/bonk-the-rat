extends Control
## Boot screen. Tap-to-start unlocks web audio context and routes to Main Menu.

func _ready() -> void:
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		am.play_music("menu")

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		set_process_input(false)
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_sfx("ui_click")
		if has_node("/root/SceneRouter"):
			get_node("/root/SceneRouter").goto("res://src/screens/main_menu.tscn")
		else:
			get_tree().change_scene_to_file("res://src/screens/main_menu.tscn")
