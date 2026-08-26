class_name Mallet
extends Node2D
## Player mallet actor following pointer input and animating bonk swings.

var _tween: Tween = null

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		var target := get_global_mouse_position()
		if target.length_squared() > 1.0:
			global_position = global_position.lerp(target, 0.65)
	queue_redraw()

func swing_at(target_pos: Vector2) -> void:
	global_position = target_pos
	if _tween != null and _tween.is_valid():
		_tween.kill()

	rotation_degrees = -65.0
	_tween = create_tween()
	_tween.tween_property(self, "rotation_degrees", 12.0, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "rotation_degrees", 0.0, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	MalletPainter.draw_mallet(self)
