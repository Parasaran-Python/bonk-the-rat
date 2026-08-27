class_name UiPainter
extends RefCounted
## Procedural vector UI graphics renderer for stars, hearts, badges and status indicators.

const GOLD_STAR_FILL := Color("ffd166")
const GOLD_STAR_OUTLINE := Color("f59e0b")
const DIM_STAR_FILL := Color(0.22, 0.26, 0.34, 0.85)
const DIM_STAR_OUTLINE := Color(0.38, 0.44, 0.54, 0.9)

const ACTIVE_HEART_FILL := Color("ef4444")
const ACTIVE_HEART_OUTLINE := Color("b91c1c")
const LOST_HEART_FILL := Color(0.20, 0.24, 0.32, 0.75)
const LOST_HEART_OUTLINE := Color(0.35, 0.40, 0.50, 0.8)

static func draw_star(canvas: CanvasItem, center: Vector2, radius: float, filled: bool = true, custom_color: Color = Color.TRANSPARENT) -> void:
	var pts := PackedVector2Array()
	for i in range(10):
		var angle := float(i) * PI / 5.0 - PI / 2.0
		var rad := radius if (i % 2 == 0) else (radius * 0.44)
		pts.append(center + Vector2(cos(angle), sin(angle)) * rad)

	var fill_col: Color = custom_color if custom_color.a > 0.0 else (GOLD_STAR_FILL if filled else DIM_STAR_FILL)
	var outline_col: Color = GOLD_STAR_OUTLINE if filled else DIM_STAR_OUTLINE

	canvas.draw_colored_polygon(pts, fill_col)
	var loop := pts.duplicate()
	loop.append(pts[0])
	canvas.draw_polyline(loop, outline_col, maxf(1.2, radius * 0.1), true)

static func draw_heart(canvas: CanvasItem, center: Vector2, size: float, active: bool = true) -> void:
	var pts := PackedVector2Array()
	var steps := 32
	var scale_factor := size / 34.0
	for i in range(steps):
		var t := float(i) / float(steps) * TAU
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		pts.append(center + Vector2(x * scale_factor, y * scale_factor + size * 0.08))

	var fill_col := ACTIVE_HEART_FILL if active else LOST_HEART_FILL
	var outline_col := ACTIVE_HEART_OUTLINE if active else LOST_HEART_OUTLINE

	canvas.draw_colored_polygon(pts, fill_col)
	var loop := pts.duplicate()
	loop.append(pts[0])
	canvas.draw_polyline(loop, outline_col, maxf(1.2, size * 0.08), true)
