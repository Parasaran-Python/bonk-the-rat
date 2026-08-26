class_name FxLayer
extends Node2D
## Visual and haptic feedback layer for impact bursts, screen shake, hit-stop and confetti.

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

	if OS.get_name() == "Android" and Input.has_method("vibrate_handheld"):
		Input.vibrate_handheld(35 if strong else 18)

func dirt_puff(pos: Vector2) -> void:
	var puff := CPUParticles2D.new()
	puff.position = pos + Vector2(0, 10)
	puff.emitting = false
	puff.one_shot = true
	puff.explosiveness = 0.9
	puff.lifetime = 0.25
	puff.amount = 8
	puff.direction = Vector2.UP
	puff.spread = 60.0
	puff.initial_velocity_min = 40.0
	puff.initial_velocity_max = 80.0
	puff.scale_amount_min = 2.5
	puff.scale_amount_max = 4.5
	puff.color = Color("854d0e")
	add_child(puff)
	puff.emitting = true

	var timer := get_tree().create_timer(0.35)
	timer.timeout.connect(puff.queue_free)

func confetti(pos: Vector2 = Vector2(640, 360)) -> void:
	var colors := [Color("38bdf8"), Color("f472b6"), Color("facc15"), Color("4ade80")]
	for c in colors:
		var burst := CPUParticles2D.new()
		burst.position = pos
		burst.emitting = false
		burst.one_shot = true
		burst.explosiveness = 0.85
		burst.lifetime = 1.2
		burst.amount = 24
		burst.direction = Vector2.UP
		burst.spread = 180.0
		burst.initial_velocity_min = 120.0
		burst.initial_velocity_max = 300.0
		burst.gravity = Vector2(0, 380)
		burst.scale_amount_min = 4.0
		burst.scale_amount_max = 8.0
		burst.color = c
		add_child(burst)
		burst.emitting = true
		var timer := get_tree().create_timer(1.4)
		timer.timeout.connect(burst.queue_free)

func hit_stop(duration_sec: float = 0.05) -> void:
	Engine.time_scale = 0.05
	var timer := get_tree().create_timer(duration_sec * 0.05, true, false, true)
	timer.timeout.connect(func(): Engine.time_scale = 1.0)

func shake(amount: float) -> void:
	var shake_enabled := true
	if is_inside_tree() and has_node("/root/Settings"):
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
