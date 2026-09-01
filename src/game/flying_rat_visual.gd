extends Node2D
## Visual canvas item delegating rendering to RatPainter for FlyingRat.

func _draw() -> void:
	var parent := get_parent()
	if parent is FlyingRat:
		RatPainter.draw_flying_rat(self, parent.flight_time, parent.state == FlyingRat.State.BONKED)
