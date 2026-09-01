class_name Mallet
extends Node2D
## Player mallet actor following pointer input and animating bonk swings.

var _tween: Tween = null
var _swinging: bool = false
var _swing_phase: float = 0.0
var _squash: Vector2 = Vector2.ONE

func is_swinging() -> bool:
	return _swinging

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

	_swinging = true
	_swing_phase = 0.0
	_squash = Vector2.ONE
	rotation_degrees = -65.0

	_tween = create_tween()
	# 1. Rapid arc down-swing to +15 deg with active motion swoosh
	_tween.parallel().tween_property(self, "rotation_degrees", 15.0, 0.065).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "_swing_phase", 1.0, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. Impact squash compression and swoosh trail dissipation
	_tween.chain().tween_property(self, "_squash", Vector2(1.25, 0.75), 0.035).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "_swing_phase", 0.0, 0.035)

	# 3. Recoil spring recovery back to neutral rest (0 deg) and normal scale
	_tween.chain().tween_property(self, "rotation_degrees", 0.0, 0.065).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "_squash", Vector2.ONE, 0.065).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 4. Lifecycle completion reset
	_tween.tween_callback(func():
		_swinging = false
		_swing_phase = 0.0
		_squash = Vector2.ONE
		rotation_degrees = 0.0
		queue_redraw()
	)

func _draw() -> void:
	MalletPainter.draw_mallet(self, _swing_phase, _squash)

