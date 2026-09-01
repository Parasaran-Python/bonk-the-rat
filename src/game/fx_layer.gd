class_name FxLayer
extends Node2D
## Visual and haptic feedback layer for impact bursts, screen shake, hit-stop and confetti.

class ShockwaveRing extends Node2D:
	var radius: float = 8.0:
		set(v):
			radius = v
			queue_redraw()
	var ring_color: Color = Color("fbbf24"):
		set(v):
			ring_color = v
			queue_redraw()
	var line_width: float = 3.5:
		set(v):
			line_width = v
			queue_redraw()

	func _draw() -> void:
		if radius > 0.0 and line_width > 0.0:
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 36, ring_color, line_width, true)
			if radius > 12.0:
				var inner_color := ring_color
				inner_color.a *= 0.35
				draw_arc(Vector2.ZERO, maxf(1.0, radius - 4.0), 0.0, TAU, 28, inner_color, maxf(1.0, line_width * 0.5), true)

var _shake_tween: Tween = null

func shockwave(pos: Vector2, color: Color = Color("fbbf24")) -> void:
	var ring := ShockwaveRing.new()
	ring.position = pos
	ring.ring_color = color
	ring.radius = 8.0
	ring.line_width = 3.5
	add_child(ring)

	if is_inside_tree():
		var tween := ring.create_tween().set_parallel(true)
		tween.tween_property(ring, "radius", 52.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(ring, "line_width", 0.6, 0.25)
		tween.tween_property(ring, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(ring.queue_free)

func impact_sparks(pos: Vector2, strong: bool = false) -> void:
	var sparks := CPUParticles2D.new()
	sparks.position = pos
	sparks.emitting = false
	sparks.one_shot = true
	sparks.explosiveness = 0.92
	sparks.lifetime = 0.25 if not strong else 0.38
	sparks.amount = 10 if not strong else 18
	sparks.direction = Vector2.UP
	sparks.spread = 45.0
	sparks.initial_velocity_min = 160.0 if not strong else 260.0
	sparks.initial_velocity_max = 280.0 if not strong else 400.0
	sparks.gravity = Vector2(0, 480)
	sparks.scale_amount_min = 2.0 if not strong else 3.5
	sparks.scale_amount_max = 4.5 if not strong else 7.0
	sparks.color = Color("ffffff") if not strong else Color("fef08a")
	add_child(sparks)
	sparks.emitting = true

	if is_inside_tree():
		var timer := get_tree().create_timer(sparks.lifetime + 0.1)
		timer.timeout.connect(sparks.queue_free)

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

	if is_inside_tree():
		var timer := get_tree().create_timer(burst.lifetime + 0.1)
		timer.timeout.connect(burst.queue_free)

	shockwave(pos, Color("fbbf24") if strong else Color("fef08a"))
	impact_sparks(pos, strong)

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

	if is_inside_tree():
		var timer := get_tree().create_timer(0.35)
		timer.timeout.connect(puff.queue_free)

func confetti(pos: Vector2 = Vector2.ZERO) -> void:
	if pos == Vector2.ZERO:
		var vp_size := get_viewport_rect().size if is_inside_tree() else Vector2(1280, 720)
		if vp_size.x <= 0 or vp_size.y <= 0:
			vp_size = Vector2(1280, 720)
		pos = Vector2(vp_size.x * 0.5, vp_size.y * 0.4)
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
		if is_inside_tree():
			var timer := get_tree().create_timer(1.4)
			timer.timeout.connect(burst.queue_free)

func hit_stop(duration_sec: float = 0.05) -> void:
	Engine.time_scale = 0.05
	if is_inside_tree():
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
