extends Control
## Boot screen. Tap-to-start unlocks web audio context.

func _ready() -> void:
	var title := Label.new()
	title.text = "BONK THE RAT!"
	title.set_anchors_preset(Control.PRESET_CENTER)
	add_child(title)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		set_process_input(false)
		print("[splash] start tapped")  # SceneRouter.goto wired in Task 13
