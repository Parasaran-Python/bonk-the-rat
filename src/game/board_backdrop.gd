extends Node2D

func _ready() -> void:
	if is_inside_tree():
		get_viewport().size_changed.connect(queue_redraw)

func _draw() -> void:
	var board := get_parent() as Board
	var t := board._theme if board != null else 1
	var vp_size := get_viewport_rect().size if is_inside_tree() else Vector2(1280, 720)
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(1280, 720)
	BackdropPainter.draw_backdrop(self, t, vp_size)
