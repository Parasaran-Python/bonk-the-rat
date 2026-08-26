class_name FxLayer
extends Node2D
## Visual and haptic feedback layer for impact bursts, screen shake and haptics.

var _shake_tween: Tween = null

func impact(pos: Vector2, strong: bool = false) -> void:
	var burst := CPUParticles2D.new()
	burst.position = pos
	burst.emitting = false
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.lifetime = 0.35 if not strong else 0.55
	burst.amount = 16 if not strong else 28
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.initial_velocity_min = 90.0 if not strong else 180.0
	burst.initial_velocity_max = 220.0 if not strong else 360.0
	burst.scale_amount_min = 3.0 if not strong else 5.0
	burst.scale_amount_max = 6.0 if not strong else 9.0
	burst.color = Color("fef08a") if not strong else Color("fbbf24")
	add_child(burst)
	burst.emitting = true

	var timer := get_tree().create_timer(burst.lifetime + 0.1)
	timer.timeout.connect(burst.queue_free)

	if strong and OS.get_name() == "Android" and Input.has_method("vibrate_handheld"):
		Input.vibrate_handheld(30)

func shake(amount: float) -> void:
	var shake_enabled := true
	if has_node("/root/Settings"):
		shake_enabled = get_node("/root/Settings").shake_enabled

	if not shake_enabled or amount <= 0.0:
		return

	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()

	var parent := get_parent() as Node2D
	if parent == null:
		return

	var orig_pos := Vector2.ZERO
	_shake_tween = create_tween()
	for i in range(4):
		var decay := 1.0 - (float(i) / 4.0)
		var offset := Vector2(randf_range(-amount, amount), randf_range(-amount, amount)) * decay
		_shake_tween.tween_property(parent, "position", orig_pos + offset, 0.03)
	_shake_tween.tween_property(parent, "position", orig_pos, 0.03)
