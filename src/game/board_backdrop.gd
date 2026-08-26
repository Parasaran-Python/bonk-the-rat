extends Node2D

func _draw() -> void:
	var board := get_parent() as Board
	var t := board._theme if board != null else 1
	BackdropPainter.draw_backdrop(self, t, Vector2(1280, 720))
