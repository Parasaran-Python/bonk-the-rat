class_name RatPainter
extends RefCounted
## Procedural 2D vector painter for all rat species, powerups and forbidden hazards.

static func draw_rat(canvas: CanvasItem, id: String, squash: Vector2 = Vector2.ONE, expression: String = "normal") -> void:
	canvas.draw_set_transform(Vector2.ZERO, 0.0, squash)
	match id:
		"whiskers":
			_draw_whiskers_cat(canvas, expression)
		"boom":
			_draw_bomb_rat(canvas, expression)
		"tank":
			_draw_tank_rat(canvas, expression)
		"golden":
			_draw_golden_rat(canvas, expression)
		"zoomer":
			_draw_zoomer_rat(canvas, expression)
		"clock":
			_draw_clock_rat(canvas, expression)
		"star":
			_draw_star_rat(canvas, expression)
		_:
			_draw_norm_rat(canvas, expression)
	if expression == "dazed":
		_draw_dazed_stars(canvas)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _draw_ears(canvas: CanvasItem, outer_col: Color, inner_col: Color, left_pos := Vector2(-26, -72), right_pos := Vector2(26, -72), radius := 14.0) -> void:
	canvas.draw_circle(left_pos, radius, outer_col)
	canvas.draw_circle(left_pos, radius * 0.65, inner_col)
	canvas.draw_circle(right_pos, radius, outer_col)
	canvas.draw_circle(right_pos, radius * 0.65, inner_col)

static func _draw_eyes(canvas: CanvasItem, left_pos := Vector2(-14, -54), right_pos := Vector2(14, -54), eye_col := Color.BLACK, r := 4.5, expression: String = "normal") -> void:
	if expression == "dazed":
		_draw_dazed_eyes(canvas, left_pos, right_pos, r)
	elif expression == "blinking":
		_draw_blinking_eyelids(canvas, left_pos, right_pos, eye_col, r)
	elif expression == "fleeing":
		_draw_fleeing_eyes(canvas, left_pos, right_pos, eye_col, r)
	else:
		canvas.draw_circle(left_pos, r, eye_col)
		canvas.draw_circle(right_pos, r, eye_col)
		canvas.draw_circle(left_pos + Vector2(-1.2, -1.2), r * 0.35, Color.WHITE)
		canvas.draw_circle(right_pos + Vector2(-1.2, -1.2), r * 0.35, Color.WHITE)

static func _draw_dazed_eyes(canvas: CanvasItem, left_pos: Vector2, right_pos: Vector2, r: float = 4.5) -> void:
	for center in [left_pos, right_pos]:
		canvas.draw_circle(center, r + 1.5, Color("fef08a"))
		var pts := PackedVector2Array()
		var loops := 2.5
		var steps := 24
		for i in range(steps):
			var t := float(i) / float(steps)
			var angle := t * loops * TAU
			var rad := (t * 0.85 + 0.15) * (r + 0.5)
			pts.append(center + Vector2(cos(angle), sin(angle)) * rad)
		canvas.draw_polyline(pts, Color("1e293b"), 1.8)

static func _draw_blinking_eyelids(canvas: CanvasItem, left_pos: Vector2, right_pos: Vector2, col: Color, r: float = 4.5) -> void:
	canvas.draw_arc(left_pos + Vector2(0, -1), r, 0.2, PI - 0.2, 12, col, 2.0)
	canvas.draw_arc(right_pos + Vector2(0, -1), r, 0.2, PI - 0.2, 12, col, 2.0)

static func _draw_fleeing_eyes(canvas: CanvasItem, left_pos: Vector2, right_pos: Vector2, pupil_col: Color, r: float = 4.5) -> void:
	canvas.draw_circle(left_pos, r + 1.5, Color.WHITE)
	canvas.draw_circle(right_pos, r + 1.5, Color.WHITE)
	canvas.draw_arc(left_pos, r + 1.5, 0.0, TAU, 16, Color("1e293b"), 1.0)
	canvas.draw_arc(right_pos, r + 1.5, 0.0, TAU, 16, Color("1e293b"), 1.0)
	canvas.draw_circle(left_pos + Vector2(1.0, -1.0), 2.0, pupil_col)
	canvas.draw_circle(right_pos + Vector2(1.0, -1.0), 2.0, pupil_col)

static func _draw_dazed_stars(canvas: CanvasItem, center := Vector2(0, -90)) -> void:
	canvas.draw_arc(center + Vector2(0, 4), 22.0, -PI * 0.9, -PI * 0.1, 16, Color(1.0, 0.85, 0.2, 0.6), 1.5)
	_draw_star_polygon(canvas, center + Vector2(-20, 2), 4.5, Color("fef08a"))
	_draw_star_polygon(canvas, center + Vector2(0, -10), 6.5, Color("fbbf24"))
	_draw_star_polygon(canvas, center + Vector2(20, 2), 4.5, Color("fef08a"))

static func _draw_snout_and_teeth(canvas: CanvasItem, snout_col: Color, nose_col: Color, expression: String = "normal") -> void:
	canvas.draw_circle(Vector2(0, -44), 14.0, snout_col)
	canvas.draw_circle(Vector2(0, -50), 5.5, nose_col)
	if expression == "dazed":
		canvas.draw_circle(Vector2(0, -36), 5.0, Color("1e293b"))
		canvas.draw_circle(Vector2(0, -34), 3.0, Color("f472b6"))
	elif expression == "fleeing":
		canvas.draw_circle(Vector2(0, -36), 4.0, Color("1e293b"))
	else:
		canvas.draw_rect(Rect2(-4, -36, 3, 6), Color.WHITE)
		canvas.draw_rect(Rect2(1, -36, 3, 6), Color.WHITE)

static func _draw_whiskers_lines(canvas: CanvasItem, col := Color(0.9, 0.9, 0.9, 0.75)) -> void:
	canvas.draw_line(Vector2(-10, -46), Vector2(-36, -52), col, 1.5)
	canvas.draw_line(Vector2(-10, -43), Vector2(-38, -43), col, 1.5)
	canvas.draw_line(Vector2(-10, -40), Vector2(-36, -34), col, 1.5)
	canvas.draw_line(Vector2(10, -46), Vector2(36, -52), col, 1.5)
	canvas.draw_line(Vector2(10, -43), Vector2(38, -43), col, 1.5)
	canvas.draw_line(Vector2(10, -40), Vector2(36, -34), col, 1.5)

static func _draw_norm_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("8d7b68")
	var belly_col := Color("c8b6a6")
	var pink_col := Color("f38ba8")
	var snout_col := Color("dfd3c3")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color.BLACK, 4.5, expression)
	_draw_whiskers_lines(canvas)

static func _draw_zoomer_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("d97706")
	var belly_col := Color("fed7aa")
	var pink_col := Color("fb7185")
	var snout_col := Color("ffedd5")

	_draw_ears(canvas, body_col, pink_col, Vector2(-28, -70), Vector2(28, -70), 12.0)
	canvas.draw_circle(Vector2(0, -40), 30.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 18.0, belly_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)

	# Goggles / headband
	canvas.draw_rect(Rect2(-24, -58, 48, 8), Color("dc2626"))
	canvas.draw_circle(Vector2(-12, -54), 7.5, Color("1e293b"))
	canvas.draw_circle(Vector2(12, -54), 7.5, Color("1e293b"))
	canvas.draw_circle(Vector2(-12, -54), 6.5, Color("64748b"))
	canvas.draw_circle(Vector2(12, -54), 6.5, Color("64748b"))

	if expression == "dazed":
		_draw_dazed_eyes(canvas, Vector2(-12, -54), Vector2(12, -54), 5.0)
	elif expression == "blinking":
		canvas.draw_circle(Vector2(-12, -54), 5.0, Color("38bdf8"))
		canvas.draw_circle(Vector2(12, -54), 5.0, Color("38bdf8"))
		_draw_blinking_eyelids(canvas, Vector2(-12, -54), Vector2(12, -54), Color("0f172a"), 5.0)
	else:
		canvas.draw_circle(Vector2(-12, -54), 5.0, Color("38bdf8"))
		canvas.draw_circle(Vector2(12, -54), 5.0, Color("38bdf8"))
		canvas.draw_line(Vector2(-15, -57), Vector2(-10, -52), Color(1, 1, 1, 0.85), 1.8)
		canvas.draw_line(Vector2(-14, -51), Vector2(-12, -49), Color(1, 1, 1, 0.6), 1.2)
		canvas.draw_line(Vector2(9, -57), Vector2(14, -52), Color(1, 1, 1, 0.85), 1.8)
		canvas.draw_line(Vector2(10, -51), Vector2(12, -49), Color(1, 1, 1, 0.6), 1.2)

	_draw_whiskers_lines(canvas)

static func _draw_tank_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("452f20")
	var belly_col := Color("78563e")
	var snout_col := Color("a78b71")
	var pink_col := Color("e17575")

	_draw_ears(canvas, body_col, pink_col, Vector2(-32, -76), Vector2(32, -76), 16.0)
	canvas.draw_circle(Vector2(0, -42), 42.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 24.0, belly_col)

	# Chin strap
	canvas.draw_line(Vector2(-30, -56), Vector2(-8, -32), Color("1e293b"), 2.5)
	canvas.draw_line(Vector2(30, -56), Vector2(8, -32), Color("1e293b"), 2.5)

	# Steel helmet dome
	var helmet_pts := PackedVector2Array([
		Vector2(-32, -56), Vector2(-28, -82), Vector2(0, -92),
		Vector2(28, -82), Vector2(32, -56)
	])
	canvas.draw_colored_polygon(helmet_pts, Color("475569"))
	canvas.draw_polyline(helmet_pts, Color("94a3b8"), 3.0)

	# Specular dome shine highlight
	var shine_pts := PackedVector2Array([
		Vector2(-18, -62), Vector2(-14, -80), Vector2(-4, -86),
		Vector2(-8, -62)
	])
	canvas.draw_colored_polygon(shine_pts, Color(0.8, 0.88, 0.95, 0.35))

	# Helmet rim band
	canvas.draw_line(Vector2(-34, -56), Vector2(34, -56), Color("cbd5e1"), 4.0)

	# Helmet rivets along rim
	for rx in [-26.0, -13.0, 0.0, 13.0, 26.0]:
		canvas.draw_circle(Vector2(rx, -56), 2.2, Color("1e293b"))
		canvas.draw_circle(Vector2(rx - 0.5, -56.5), 1.0, Color("f8fafc"))

	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -50), Vector2(14, -50), Color.BLACK, 5.0, expression)
	_draw_whiskers_lines(canvas)

static func _draw_golden_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("fbbf24")
	var belly_col := Color("fef08a")
	var snout_col := Color("fffbeb")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Sparkle crown
	var crown_pts := PackedVector2Array([
		Vector2(-18, -68), Vector2(-14, -86), Vector2(-7, -74),
		Vector2(0, -92), Vector2(7, -74), Vector2(14, -86), Vector2(18, -68)
	])
	canvas.draw_colored_polygon(crown_pts, Color("fef08a"))
	canvas.draw_polyline(crown_pts, Color("d97706"), 2.0)
	canvas.draw_line(Vector2(-19, -68), Vector2(19, -68), Color("b45309"), 2.5)

	# Crown jewels
	canvas.draw_circle(Vector2(0, -78), 3.0, Color("ef4444"))
	canvas.draw_circle(Vector2(0, -78.5), 1.0, Color.WHITE)
	canvas.draw_circle(Vector2(-10, -74), 2.2, Color("3b82f6"))
	canvas.draw_circle(Vector2(10, -74), 2.2, Color("3b82f6"))

	# Sparkle glints
	_draw_star_polygon(canvas, Vector2(0, -92), 3.5, Color.WHITE)
	_draw_star_polygon(canvas, Vector2(-14, -86), 2.5, Color.WHITE)
	_draw_star_polygon(canvas, Vector2(14, -86), 2.5, Color.WHITE)

	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color("78350f"), 5.0, expression)
	_draw_whiskers_lines(canvas, Color("fde047"))

static func _draw_clock_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("64748b")
	var belly_col := Color("94a3b8")
	var snout_col := Color("cbd5e1")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Stopwatch badge
	canvas.draw_rect(Rect2(-2, -39, 4, 3), Color("0284c7"))
	canvas.draw_circle(Vector2(0, -25), 12.0, Color("0284c7"))
	canvas.draw_circle(Vector2(0, -25), 10.0, Color.WHITE)
	for i in range(8):
		var angle := i * TAU / 8.0
		var inner := Vector2(0, -25) + Vector2(cos(angle), sin(angle)) * 7.5
		var outer := Vector2(0, -25) + Vector2(cos(angle), sin(angle)) * 9.5
		canvas.draw_line(inner, outer, Color("94a3b8"), 1.0)
	canvas.draw_line(Vector2(0, -25), Vector2(0, -32), Color("0f172a"), 2.0)
	canvas.draw_line(Vector2(0, -25), Vector2(5, -25), Color("ef4444"), 1.5)
	canvas.draw_circle(Vector2(0, -25), 1.5, Color("0f172a"))

	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color.BLACK, 4.5, expression)
	_draw_whiskers_lines(canvas)

static func _draw_star_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("facc15")
	var belly_col := Color("fef9c3")
	var snout_col := Color("ffffff")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Star emblem and halo
	canvas.draw_arc(Vector2(0, -68), 13.0, 0.0, TAU, 20, Color(1.0, 0.8, 0.2, 0.4), 2.0)
	_draw_star_polygon(canvas, Vector2(0, -68), 10.0, Color("f97316"))
	_draw_star_polygon(canvas, Vector2(0, -68), 6.5, Color("fef08a"))

	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color.BLACK, 4.5, expression)
	_draw_whiskers_lines(canvas)

static func _draw_whiskers_cat(canvas: CanvasItem, expression: String = "normal") -> void:
	var cat_col := Color("334155")
	var belly_col := Color("475569")
	var pink_col := Color("f472b6")
	var eye_col := Color("10b981")

	# Cat triangle ears
	var left_ear := PackedVector2Array([Vector2(-32, -54), Vector2(-24, -86), Vector2(-10, -66)])
	var right_ear := PackedVector2Array([Vector2(32, -54), Vector2(24, -86), Vector2(10, -66)])
	canvas.draw_colored_polygon(left_ear, cat_col)
	canvas.draw_colored_polygon(right_ear, cat_col)
	var left_inner := PackedVector2Array([Vector2(-28, -58), Vector2(-23, -80), Vector2(-14, -66)])
	var right_inner := PackedVector2Array([Vector2(28, -58), Vector2(23, -80), Vector2(14, -66)])
	canvas.draw_colored_polygon(left_inner, pink_col)
	canvas.draw_colored_polygon(right_inner, pink_col)

	canvas.draw_circle(Vector2(0, -42), 34.0, cat_col)
	canvas.draw_circle(Vector2(0, -34), 20.0, belly_col)

	if expression == "dazed":
		_draw_dazed_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), 6.0)
	elif expression == "blinking":
		_draw_blinking_eyelids(canvas, Vector2(-14, -54), Vector2(14, -54), eye_col, 6.0)
	elif expression == "fleeing":
		_draw_fleeing_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), eye_col, 6.0)
	else:
		canvas.draw_circle(Vector2(-14, -54), 6.0, eye_col)
		canvas.draw_circle(Vector2(14, -54), 6.0, eye_col)
		canvas.draw_rect(Rect2(-15, -59, 2, 10), Color.BLACK)
		canvas.draw_rect(Rect2(13, -59, 2, 10), Color.BLACK)
		canvas.draw_circle(Vector2(-15, -56), 1.5, Color.WHITE)
		canvas.draw_circle(Vector2(13, -56), 1.5, Color.WHITE)

	# Pink nose & mouth
	var nose_pts := PackedVector2Array([Vector2(-5, -45), Vector2(5, -45), Vector2(0, -40)])
	canvas.draw_colored_polygon(nose_pts, pink_col)
	if expression == "dazed":
		canvas.draw_circle(Vector2(0, -36), 4.5, Color("1e293b"))
		canvas.draw_circle(Vector2(0, -34), 2.5, pink_col)
	else:
		canvas.draw_line(Vector2(0, -40), Vector2(0, -36), Color("1e293b"), 2.0)
		canvas.draw_line(Vector2(0, -36), Vector2(-6, -34), Color("1e293b"), 2.0)
		canvas.draw_line(Vector2(0, -36), Vector2(6, -34), Color("1e293b"), 2.0)

	_draw_whiskers_lines(canvas, Color.WHITE)

static func _draw_bomb_rat(canvas: CanvasItem, expression: String = "normal") -> void:
	var body_col := Color("52525b")
	var snout_col := Color("a1a1aa")
	var pink_col := Color("fb7185")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -42), 34.0, body_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col, expression)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color.BLACK, 4.5, expression)

	# Big black bomb
	canvas.draw_circle(Vector2(0, -32), 24.0, Color("18181b"))
	canvas.draw_circle(Vector2(-6, -38), 5.0, Color("3f3f46"))
	canvas.draw_circle(Vector2(-8, -40), 2.0, Color("71717a"))

	# Fuse cap
	canvas.draw_rect(Rect2(-4, -58, 8, 4), Color("71717a"))

	# Sizzling fuse & sparks
	var fuse_pts := PackedVector2Array([
		Vector2(0, -58), Vector2(4, -68), Vector2(12, -76)
	])
	canvas.draw_polyline(fuse_pts, Color("92400e"), 2.5)

	var spark_pos := Vector2(12, -76)
	_draw_star_polygon(canvas, spark_pos, 8.0, Color("ea580c"))
	_draw_star_polygon(canvas, spark_pos, 5.5, Color("facc15"))
	canvas.draw_circle(spark_pos, 2.0, Color.WHITE)
	canvas.draw_circle(spark_pos + Vector2(4, -4), 1.2, Color("fef08a"))
	canvas.draw_circle(spark_pos + Vector2(-3, -5), 1.0, Color("f97316"))
	canvas.draw_circle(spark_pos + Vector2(5, 3), 1.0, Color("fbbf24"))

static func _draw_star_polygon(canvas: CanvasItem, center: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(10):
		var angle := i * PI / 5.0 - PI / 2.0
		var rad := r if (i % 2 == 0) else (r * 0.45)
		pts.append(center + Vector2(cos(angle), sin(angle)) * rad)
	canvas.draw_colored_polygon(pts, col)

static func draw_flying_rat(canvas: CanvasItem, t_anim: float = 0.0, is_hit: bool = false) -> void:
	# 1. Wings (behind body)
	var flap: float = sin(t_anim * 14.0)
	if is_hit:
		flap = sin(t_anim * 28.0) * 0.4
	_draw_glider_wings(canvas, flap)

	# 2. Dangling Golden Prize / Pouch
	_draw_prize_pouch(canvas, t_anim)

	# 3. Rat Body
	var body_col := Color("64748b")
	var belly_col := Color("94a3b8")
	var pink_col := Color("f472b6")
	var snout_col := Color("cbd5e1")

	_draw_ears(canvas, body_col, pink_col, Vector2(-28, -66), Vector2(28, -66), 13.0)
	canvas.draw_circle(Vector2(0, -36), 32.0, body_col)
	canvas.draw_circle(Vector2(0, -28), 18.0, belly_col)

	# Leather Aviator Helmet
	var helmet_col := Color("451a03")
	var helmet_dark := Color("291002")
	var helmet_pts := PackedVector2Array([
		Vector2(-30, -50), Vector2(-28, -78), Vector2(0, -86),
		Vector2(28, -78), Vector2(30, -50), Vector2(24, -36),
		Vector2(18, -38), Vector2(16, -52), Vector2(-16, -52),
		Vector2(-18, -38), Vector2(-24, -36)
	])
	canvas.draw_colored_polygon(helmet_pts, helmet_col)
	canvas.draw_polyline(helmet_pts, helmet_dark, 2.0)

	# Chin strap & buckle
	canvas.draw_line(Vector2(-24, -36), Vector2(-6, -20), helmet_col, 3.0)
	canvas.draw_line(Vector2(24, -36), Vector2(6, -20), helmet_col, 3.0)
	canvas.draw_line(Vector2(-7, -20), Vector2(7, -20), Color("d97706"), 3.0)

	# Snout and whiskers
	var expr := "dazed" if is_hit else "normal"
	_draw_snout_and_teeth(canvas, snout_col, pink_col, expr)
	_draw_whiskers_lines(canvas, Color(0.9, 0.9, 0.9, 0.8))

	# Pilot Goggles
	_draw_pilot_goggles(canvas, is_hit)

	if is_hit:
		_draw_dazed_stars(canvas, Vector2(0, -96))

static func _draw_glider_wings(canvas: CanvasItem, flap: float) -> void:
	var wing_dark := Color("1e293b")
	var wing_skin := Color("334155")
	var spar_col := Color("64748b")

	# Left Wing
	var left_joint := Vector2(-16, -32)
	var left_elbow := Vector2(-42, -54 - flap * 22.0)
	var left_tip := Vector2(-74, -38 - flap * 26.0)
	var left_dip1 := Vector2(-58, -22 - flap * 14.0)
	var left_dip2 := Vector2(-38, -18 - flap * 8.0)
	var left_base := Vector2(-16, -24)

	var left_pts := PackedVector2Array([
		left_joint, left_elbow, left_tip, left_dip1, left_dip2, left_base
	])
	canvas.draw_colored_polygon(left_pts, wing_skin)
	canvas.draw_polyline(left_pts, wing_dark, 2.0)
	canvas.draw_line(left_joint, left_elbow, spar_col, 2.5)
	canvas.draw_line(left_elbow, left_tip, spar_col, 2.0)
	canvas.draw_line(left_elbow, left_dip1, spar_col, 1.5)
	canvas.draw_line(left_joint, left_dip2, spar_col, 1.5)

	# Right Wing (symmetric)
	var right_joint := Vector2(16, -32)
	var right_elbow := Vector2(42, -54 - flap * 22.0)
	var right_tip := Vector2(74, -38 - flap * 26.0)
	var right_dip1 := Vector2(58, -22 - flap * 14.0)
	var right_dip2 := Vector2(38, -18 - flap * 8.0)
	var right_base := Vector2(16, -24)

	var right_pts := PackedVector2Array([
		right_joint, right_elbow, right_tip, right_dip1, right_dip2, right_base
	])
	canvas.draw_colored_polygon(right_pts, wing_skin)
	canvas.draw_polyline(right_pts, wing_dark, 2.0)
	canvas.draw_line(right_joint, right_elbow, spar_col, 2.5)
	canvas.draw_line(right_elbow, right_tip, spar_col, 2.0)
	canvas.draw_line(right_elbow, right_dip1, spar_col, 1.5)
	canvas.draw_line(right_joint, right_dip2, spar_col, 1.5)

static func _draw_pilot_goggles(canvas: CanvasItem, is_hit: bool) -> void:
	# Strap
	canvas.draw_line(Vector2(-30, -54), Vector2(30, -54), Color("1e293b"), 4.5)
	# Bridge
	canvas.draw_line(Vector2(-5, -54), Vector2(5, -54), Color("b45309"), 3.5)

	var left_eye := Vector2(-13, -54)
	var right_eye := Vector2(13, -54)

	for center in [left_eye, right_eye]:
		# Brass outer frame
		canvas.draw_circle(center, 8.5, Color("b45309"))
		# Dark inner frame
		canvas.draw_circle(center, 7.0, Color("1e293b"))
		# Glass lens
		canvas.draw_circle(center, 5.5, Color("38bdf8"))

	if is_hit:
		_draw_dazed_eyes(canvas, left_eye, right_eye, 5.0)
	else:
		for center in [left_eye, right_eye]:
			canvas.draw_circle(center + Vector2(1.0, 0), 2.5, Color("0f172a"))
			canvas.draw_line(center + Vector2(-3.5, -3.5), center + Vector2(1.0, 1.0), Color(1, 1, 1, 0.85), 1.6)
			canvas.draw_circle(center + Vector2(2.5, 2.5), 1.0, Color(1, 1, 1, 0.7))

static func _draw_prize_pouch(canvas: CanvasItem, t_anim: float) -> void:
	var swing: float = sin(t_anim * 6.0) * 3.0
	var pouch_center := Vector2(swing, 18.0)

	# Suspension straps
	canvas.draw_line(Vector2(-10, -18), Vector2(-6 + swing, 10), Color("78350f"), 1.8)
	canvas.draw_line(Vector2(10, -18), Vector2(6 + swing, 10), Color("78350f"), 1.8)

	# Glowing aura
	canvas.draw_circle(pouch_center, 18.0, Color(1.0, 0.85, 0.2, 0.25))

	# Cheese wedge polygon
	var cheese_pts := PackedVector2Array([
		Vector2(-14 + swing, 24),
		Vector2(14 + swing, 24),
		Vector2(0 + swing, 8)
	])
	canvas.draw_colored_polygon(cheese_pts, Color("fbbf24"))
	canvas.draw_polyline(PackedVector2Array([
		cheese_pts[0], cheese_pts[1], cheese_pts[2], cheese_pts[0]
	]), Color("d97706"), 2.0)

	# Cheese holes
	canvas.draw_circle(pouch_center + Vector2(-4, 2), 2.5, Color("d97706"))
	canvas.draw_circle(pouch_center + Vector2(4, 3), 1.8, Color("d97706"))
	canvas.draw_circle(pouch_center + Vector2(0, -3), 1.5, Color("d97706"))

	# Sparkling star glints
	var glint_pulse: float = (sin(t_anim * 8.0) + 1.0) * 0.5
	_draw_star_polygon(canvas, pouch_center + Vector2(12, -4), 3.0 + glint_pulse * 2.0, Color.WHITE)
	_draw_star_polygon(canvas, pouch_center + Vector2(-12, 4), 2.0 + (1.0 - glint_pulse) * 1.5, Color("fef08a"))


