extends Node2D
## Visual canvas item delegating rendering to RatPainter.

func _draw() -> void:
	var parent := get_parent()
	if parent is Rat:
		RatPainter.draw_rat(self, parent.rat_id, parent.scale_visual())
