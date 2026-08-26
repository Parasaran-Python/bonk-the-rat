extends Node
## Global screen router managing smooth cross-fade transitions and navigation history.

var current_args: Dictionary = {}
var _history: Array[String] = []
var _layer: CanvasLayer = null
var _fade_rect: ColorRect = null
var _is_transitioning := false

func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 128
	_layer.name = "TransitionLayer"
	add_child(_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_fade_rect)

func goto(path: String, args: Dictionary = {}) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	current_args = args

	var tree := get_tree()
	if tree != null and tree.current_scene != null:
		var curr_path := tree.current_scene.scene_file_path
		if curr_path != "" and curr_path != path:
			_history.append(curr_path)

	if _fade_rect == null or not is_inside_tree():
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
		_is_transitioning = false
		return

	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
	)
	tw.tween_interval(0.05)
	tw.tween_property(_fade_rect, "color:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_is_transitioning = false
	)

func back() -> void:
	if not _history.is_empty():
		var prev: String = str(_history.pop_back())
		goto(prev)
	else:
		goto("res://src/screens/main_menu.tscn")
