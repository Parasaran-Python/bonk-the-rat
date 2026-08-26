extends Node2D

func _draw() -> void:
	var hole := get_parent() as Hole
	var t := hole.theme if hole != null else 1
	HolePainter.draw_hole(self, t)
