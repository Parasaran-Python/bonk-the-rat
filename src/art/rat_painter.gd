class_name RatPainter
extends RefCounted
## Procedural 2D vector painter for all rat species, powerups and forbidden hazards.

static func draw_rat(canvas: CanvasItem, id: String, squash: Vector2 = Vector2.ONE) -> void:
	canvas.draw_set_transform(Vector2.ZERO, 0.0, squash)
	match id:
		"whiskers":
			_draw_whiskers_cat(canvas)
		"boom":
			_draw_bomb_rat(canvas)
		"tank":
			_draw_tank_rat(canvas)
		"golden":
			_draw_golden_rat(canvas)
		"zoomer":
			_draw_zoomer_rat(canvas)
		"clock":
			_draw_clock_rat(canvas)
		"star":
			_draw_star_rat(canvas)
		_:
			_draw_norm_rat(canvas)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _draw_ears(canvas: CanvasItem, outer_col: Color, inner_col: Color, left_pos := Vector2(-26, -72), right_pos := Vector2(26, -72), radius := 14.0) -> void:
	canvas.draw_circle(left_pos, radius, outer_col)
	canvas.draw_circle(left_pos, radius * 0.65, inner_col)
	canvas.draw_circle(right_pos, radius, outer_col)
	canvas.draw_circle(right_pos, radius * 0.65, inner_col)

static func _draw_eyes(canvas: CanvasItem, left_pos := Vector2(-14, -54), right_pos := Vector2(14, -54), eye_col := Color.BLACK, r := 4.5) -> void:
	canvas.draw_circle(left_pos, r, eye_col)
	canvas.draw_circle(right_pos, r, eye_col)
	canvas.draw_circle(left_pos + Vector2(-1.2, -1.2), r * 0.35, Color.WHITE)
	canvas.draw_circle(right_pos + Vector2(-1.2, -1.2), r * 0.35, Color.WHITE)

static func _draw_snout_and_teeth(canvas: CanvasItem, snout_col: Color, nose_col: Color) -> void:
	canvas.draw_circle(Vector2(0, -44), 14.0, snout_col)
	canvas.draw_circle(Vector2(0, -50), 5.5, nose_col)
	canvas.draw_rect(Rect2(-4, -36, 3, 6), Color.WHITE)
	canvas.draw_rect(Rect2(1, -36, 3, 6), Color.WHITE)

static func _draw_whiskers_lines(canvas: CanvasItem, col := Color(0.9, 0.9, 0.9, 0.75)) -> void:
	canvas.draw_line(Vector2(-10, -46), Vector2(-36, -52), col, 1.5)
	canvas.draw_line(Vector2(-10, -43), Vector2(-38, -43), col, 1.5)
	canvas.draw_line(Vector2(-10, -40), Vector2(-36, -34), col, 1.5)
	canvas.draw_line(Vector2(10, -46), Vector2(36, -52), col, 1.5)
	canvas.draw_line(Vector2(10, -43), Vector2(38, -43), col, 1.5)
	canvas.draw_line(Vector2(10, -40), Vector2(36, -34), col, 1.5)

static func _draw_norm_rat(canvas: CanvasItem) -> void:
	var body_col := Color("8d7b68")
	var belly_col := Color("c8b6a6")
	var pink_col := Color("f38ba8")
	var snout_col := Color("dfd3c3")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas)
	_draw_whiskers_lines(canvas)

static func _draw_zoomer_rat(canvas: CanvasItem) -> void:
	var body_col := Color("d97706")
	var belly_col := Color("fed7aa")
	var pink_col := Color("fb7185")
	var snout_col := Color("ffedd5")

	_draw_ears(canvas, body_col, pink_col, Vector2(-28, -70), Vector2(28, -70), 12.0)
	canvas.draw_circle(Vector2(0, -40), 30.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 18.0, belly_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col)

	# Goggles / headband
	canvas.draw_rect(Rect2(-24, -58, 48, 8), Color("dc2626"))
	canvas.draw_circle(Vector2(-12, -54), 7.0, Color("1e293b"))
	canvas.draw_circle(Vector2(12, -54), 7.0, Color("1e293b"))
	canvas.draw_circle(Vector2(-12, -54), 5.0, Color("38bdf8"))
	canvas.draw_circle(Vector2(12, -54), 5.0, Color("38bdf8"))
	canvas.draw_circle(Vector2(-13, -56), 2.0, Color.WHITE)
	canvas.draw_circle(Vector2(11, -56), 2.0, Color.WHITE)
	_draw_whiskers_lines(canvas)

static func _draw_tank_rat(canvas: CanvasItem) -> void:
	var body_col := Color("452f20")
	var belly_col := Color("78563e")
	var snout_col := Color("a78b71")
	var pink_col := Color("e17575")

	_draw_ears(canvas, body_col, pink_col, Vector2(-32, -76), Vector2(32, -76), 16.0)
	canvas.draw_circle(Vector2(0, -42), 42.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 24.0, belly_col)

	# Steel helmet dome
	var helmet_pts := PackedVector2Array([
		Vector2(-32, -56), Vector2(-28, -82), Vector2(0, -92),
		Vector2(28, -82), Vector2(32, -56)
	])
	canvas.draw_colored_polygon(helmet_pts, Color("475569"))
	canvas.draw_polyline(helmet_pts, Color("94a3b8"), 3.0)
	canvas.draw_line(Vector2(-34, -56), Vector2(34, -56), Color("cbd5e1"), 4.0)

	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas, Vector2(-14, -50), Vector2(14, -50), Color.BLACK, 5.0)
	_draw_whiskers_lines(canvas)

static func _draw_golden_rat(canvas: CanvasItem) -> void:
	var body_col := Color("fbbf24")
	var belly_col := Color("fef08a")
	var snout_col := Color("fffbeb")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Sparkle crown
	var crown_pts := PackedVector2Array([
		Vector2(-18, -68), Vector2(-12, -84), Vector2(-4, -72),
		Vector2(0, -88), Vector2(4, -72), Vector2(12, -84), Vector2(18, -68)
	])
	canvas.draw_colored_polygon(crown_pts, Color("fef08a"))
	canvas.draw_polyline(crown_pts, Color("d97706"), 2.0)

	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas, Vector2(-14, -54), Vector2(14, -54), Color("78350f"), 5.0)
	_draw_whiskers_lines(canvas, Color("fde047"))

static func _draw_clock_rat(canvas: CanvasItem) -> void:
	var body_col := Color("64748b")
	var belly_col := Color("94a3b8")
	var snout_col := Color("cbd5e1")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Stopwatch badge
	canvas.draw_circle(Vector2(0, -26), 11.0, Color("0ea5e9"))
	canvas.draw_circle(Vector2(0, -26), 9.0, Color.WHITE)
	canvas.draw_line(Vector2(0, -26), Vector2(0, -33), Color("0f172a"), 2.0)
	canvas.draw_line(Vector2(0, -26), Vector2(5, -26), Color("0f172a"), 2.0)

	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas)
	_draw_whiskers_lines(canvas)

static func _draw_star_rat(canvas: CanvasItem) -> void:
	var body_col := Color("facc15")
	var belly_col := Color("fef9c3")
	var snout_col := Color("ffffff")
	var pink_col := Color("f472b6")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -40), 34.0, body_col)
	canvas.draw_circle(Vector2(0, -32), 20.0, belly_col)

	# Star emblem
	_draw_star_polygon(canvas, Vector2(0, -68), 9.0, Color("f97316"))

	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas)
	_draw_whiskers_lines(canvas)

static func _draw_whiskers_cat(canvas: CanvasItem) -> void:
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

	# Cat green almond eyes
	canvas.draw_circle(Vector2(-14, -54), 6.0, eye_col)
	canvas.draw_circle(Vector2(14, -54), 6.0, eye_col)
	canvas.draw_rect(Rect2(-15, -59, 2, 10), Color.BLACK)
	canvas.draw_rect(Rect2(13, -59, 2, 10), Color.BLACK)

	# Pink nose & mouth
	var nose_pts := PackedVector2Array([Vector2(-5, -45), Vector2(5, -45), Vector2(0, -40)])
	canvas.draw_colored_polygon(nose_pts, pink_col)
	canvas.draw_line(Vector2(0, -40), Vector2(0, -36), Color("1e293b"), 2.0)
	canvas.draw_line(Vector2(0, -36), Vector2(-6, -34), Color("1e293b"), 2.0)
	canvas.draw_line(Vector2(0, -36), Vector2(6, -34), Color("1e293b"), 2.0)

	# Distinctive long white whiskers
	_draw_whiskers_lines(canvas, Color.WHITE)

static func _draw_bomb_rat(canvas: CanvasItem) -> void:
	var body_col := Color("52525b")
	var snout_col := Color("a1a1aa")
	var pink_col := Color("fb7185")

	_draw_ears(canvas, body_col, pink_col)
	canvas.draw_circle(Vector2(0, -42), 34.0, body_col)
	_draw_snout_and_teeth(canvas, snout_col, pink_col)
	_draw_eyes(canvas)

	# Big black bomb
	canvas.draw_circle(Vector2(0, -32), 24.0, Color("18181b"))
	canvas.draw_circle(Vector2(-6, -38), 5.0, Color("3f3f46"))

	# Fuse & spark
	canvas.draw_line(Vector2(0, -56), Vector2(10, -74), Color("d97706"), 3.0)
	_draw_star_polygon(canvas, Vector2(10, -74), 7.0, Color("fbbf24"))

static func _draw_star_polygon(canvas: CanvasItem, center: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(10):
		var angle := i * PI / 5.0 - PI / 2.0
		var rad := r if (i % 2 == 0) else (r * 0.45)
		pts.append(center + Vector2(cos(angle), sin(angle)) * rad)
	canvas.draw_colored_polygon(pts, col)
