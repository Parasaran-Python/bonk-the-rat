class_name MalletPainter
extends RefCounted
## Procedural painter for the player's mallet / hammer.

static func draw_mallet(canvas: CanvasItem, swing_phase: float = 0.0, squash: Vector2 = Vector2.ONE) -> void:
	# 1. Motion Swoosh Arc Trail (rendered behind hammer during down-swing)
	if swing_phase > 0.05:
		var alpha := clampf(swing_phase, 0.0, 1.0) * 0.75
		var swoosh_col := Color(1.0, 1.0, 0.95, alpha)
		var swoosh_outer := Color(0.98, 0.85, 0.45, alpha * 0.6)
		# Arc swoosh sweeping behind the hammer head
		var start_angle := -PI * 0.68
		var end_angle := -PI * 0.68 + (PI * 0.60 * swing_phase)
		canvas.draw_arc(Vector2(0, 15), 46.0, start_angle, end_angle, 20, swoosh_outer, 6.0, true)
		canvas.draw_arc(Vector2(0, 15), 48.0, start_angle, end_angle, 20, swoosh_col, 3.0, true)
		canvas.draw_arc(Vector2(0, 15), 52.0, start_angle, end_angle, 20, Color(1.0, 1.0, 1.0, alpha * 0.8), 1.5, true)

	# 2. Wooden Handle extending downwards from head
	var handle_col := Color("78350f") # Warm polished hardwood
	var handle_pts := PackedVector2Array([
		Vector2(-6, -10), Vector2(6, -10),
		Vector2(5, 62), Vector2(-5, 62)
	])
	canvas.draw_colored_polygon(handle_pts, handle_col)
	# Handle wood grain & outline
	canvas.draw_polyline(handle_pts, Color("3b1a03"), 2.0)
	canvas.draw_line(Vector2(-1.5, -6), Vector2(-1.5, 58), Color("92400e"), 1.2) # Subtle wood grain streak
	# Handle pommel rounded base cap
	canvas.draw_circle(Vector2(0, 62), 6.5, Color("451a03"))
	canvas.draw_circle(Vector2(0, 62), 4.5, Color("78350f"))
	canvas.draw_circle(Vector2(0, 62), 2.0, Color("fbbf24")) # Pommel brass rivet

	# 3. Leather Grip with criss-cross wrap pattern on handle
	var grip_base := PackedVector2Array([
		Vector2(-5.5, 14), Vector2(5.5, 14),
		Vector2(5, 54), Vector2(-5, 54)
	])
	canvas.draw_colored_polygon(grip_base, Color("381e0d")) # Dark leather underlayer
	# Grip end collars (brass/gold rings at top & bottom of grip)
	canvas.draw_rect(Rect2(-6, 12, 12, 3), Color("f59e0b"))
	canvas.draw_rect(Rect2(-5.5, 53, 11, 3), Color("f59e0b"))
	# Criss-cross diamond leather wraps
	var wrap_ys: Array[float] = [18.0, 26.0, 34.0, 42.0, 50.0]
	for y in wrap_ys:
		# Left-to-right diagonal strap
		canvas.draw_line(Vector2(-5.5, y - 4), Vector2(5.5, y + 4), Color("b45309"), 2.0)
		# Right-to-left diagonal strap
		canvas.draw_line(Vector2(5.5, y - 4), Vector2(-5.5, y + 4), Color("d97706"), 1.6)
		# Wrap stitching highlight
		canvas.draw_line(Vector2(-5.5, y - 4), Vector2(5.5, y + 4), Color(1.0, 0.9, 0.7, 0.35), 0.8)

	# 4. Polished Mahogany Mallet Head (with squash deformation)
	var base_hw := 35.0 * squash.x
	var base_hh := 16.0 * squash.y
	var head_center_y := -20.0
	var head_rect := Rect2(-base_hw, head_center_y - base_hh, base_hw * 2.0, base_hh * 2.0)

	# Drop shadow underneath head
	canvas.draw_circle(Vector2(2, head_center_y + base_hh * 0.4), base_hw * 0.7, Color(0.0, 0.0, 0.0, 0.22))

	# Deep rich mahogany wood body
	canvas.draw_rect(head_rect, Color("881337")) # Polished mahogany / deep cherry
	# Subtle inner wood gradient tone
	var inner_rect := Rect2(-base_hw + 2, head_center_y - base_hh + 3, (base_hw - 2) * 2.0, (base_hh - 3) * 2.0)
	canvas.draw_rect(inner_rect, Color("9f1239"))

	# Head outer outline / shadow border
	canvas.draw_rect(head_rect, Color("4c0519"), false, 2.5)

	# 5. Top-Edge Bevel and Highlight Specular Reflection
	var top_y := head_center_y - base_hh
	var bot_y := head_center_y + base_hh
	# Top specular highlight line
	canvas.draw_line(Vector2(-base_hw + 4, top_y + 2.5), Vector2(base_hw - 4, top_y + 2.5), Color(1.0, 1.0, 1.0, 0.65), 2.2)
	# Secondary reflection sheen
	canvas.draw_line(Vector2(-base_hw + 10, top_y + 6.0), Vector2(base_hw - 12, top_y + 6.0), Color(1.0, 0.9, 0.85, 0.3), 1.5)
	# Bottom bevel shadow
	canvas.draw_line(Vector2(-base_hw + 3, bot_y - 2.0), Vector2(base_hw - 3, bot_y - 2.0), Color(0.12, 0.02, 0.05, 0.6), 2.0)

	# 6. Dual Metallic Brass Retention Bands with Specular Shine
	var band_w := 6.5 * squash.x
	var band_offset_x := base_hw * 0.52
	var left_band_rect := Rect2(-band_offset_x - band_w * 0.5, top_y, band_w, base_hh * 2.0)
	var right_band_rect := Rect2(band_offset_x - band_w * 0.5, top_y, band_w, base_hh * 2.0)

	for b_rect in [left_band_rect, right_band_rect]:
		# Brass band base
		canvas.draw_rect(b_rect, Color("f59e0b"))
		# Brass dark border
		canvas.draw_rect(b_rect, Color("92400e"), false, 1.5)
		# Brass bright specular shine glint
		var glint_x: float = b_rect.position.x + b_rect.size.x * 0.35
		canvas.draw_line(Vector2(glint_x, top_y + 2), Vector2(glint_x, bot_y - 2), Color("fef08a"), 1.8)
		canvas.draw_line(Vector2(glint_x, top_y + 4), Vector2(glint_x, top_y + 10), Color(1.0, 1.0, 1.0, 0.9), 1.5)

	# Center bronze inlay ring around handle socket
	var center_band_w := 12.0 * squash.x
	var center_rect := Rect2(-center_band_w * 0.5, top_y, center_band_w, base_hh * 2.0)
	canvas.draw_rect(center_rect, Color("451a03"))
	canvas.draw_rect(center_rect, Color("b45309"), false, 1.2)
	# Center decorative brass rivet
	canvas.draw_circle(Vector2(0, head_center_y), 2.8 * minf(squash.x, squash.y), Color("fbbf24"))
	canvas.draw_circle(Vector2(0, head_center_y), 1.2, Color(1.0, 1.0, 1.0, 0.8))

	# 7. Impact Face Caps (reinforced brass/steel strike plates on left & right)
	# Left face strike plate
	canvas.draw_line(Vector2(-base_hw, top_y + 1), Vector2(-base_hw, bot_y - 1), Color("fbbf24"), 3.5)
	canvas.draw_line(Vector2(-base_hw - 1.5, top_y + 4), Vector2(-base_hw - 1.5, bot_y - 4), Color("fde047"), 1.8)
	# Right face strike plate
	canvas.draw_line(Vector2(base_hw, top_y + 1), Vector2(base_hw, bot_y - 1), Color("fbbf24"), 3.5)
	canvas.draw_line(Vector2(base_hw + 1.5, top_y + 4), Vector2(base_hw + 1.5, bot_y - 4), Color("fde047"), 1.8)
