class_name HolePainter
extends RefCounted
## Procedural painter for board holes with layered foreground rim rendering.

static func draw_hole(canvas: CanvasItem, theme: int) -> void:
	var pal := Palettes.for_zone(theme)
	var dirt_col: Color = pal["dirt"]
	var shadow_col: Color = pal["shadow"]

	# Outer ground dirt ring
	_draw_ellipse(canvas, Vector2(0, 4), 68.0, 24.0, dirt_col.darkened(0.2))
	# Hole rim outline
	_draw_ellipse(canvas, Vector2(0, 0), 64.0, 22.0, dirt_col)
	# Inner deep black/shadow cavity
	_draw_ellipse(canvas, Vector2(0, 0), 58.0, 18.0, Color("110f13"))
	_draw_ellipse(canvas, Vector2(0, -3), 52.0, 12.0, shadow_col)

static func draw_rim_front(canvas: CanvasItem, theme: int) -> void:
	var pal := Palettes.for_zone(theme)
	var dirt_col: Color = pal["dirt"]
	var wood_col: Color = pal["wood"]

	# Draw front lower-half rim for depth clipping
	var pts := PackedVector2Array()
	var steps := 24
	for i in range(steps + 1):
		var angle := float(i) * PI / float(steps)
		pts.append(Vector2(cos(angle) * 62.0, sin(angle) * 20.0))
	for i in range(steps, -1, -1):
		var angle := float(i) * PI / float(steps)
		pts.append(Vector2(cos(angle) * 66.0, sin(angle) * 24.0 + 3.0))

	canvas.draw_colored_polygon(pts, dirt_col)
	canvas.draw_polyline(pts, wood_col.darkened(0.3), 2.0)

static func _draw_ellipse(canvas: CanvasItem, center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var steps := 32
	for i in range(steps):
		var angle := float(i) * TAU / float(steps)
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	canvas.draw_colored_polygon(pts, col)
