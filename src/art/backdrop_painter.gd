class_name BackdropPainter
extends RefCounted
## Procedural backdrop painter for the 3 zone themes.

static func draw_backdrop(canvas: CanvasItem, theme: int, size: Vector2) -> void:
	var pal := Palettes.for_zone(theme)
	var bg: Color = pal["bg"]
	var bg_dark: Color = pal["bg_dark"]
	var wood: Color = pal["wood"]
	var accent: Color = pal["accent"]

	# Base full canvas fill
	canvas.draw_rect(Rect2(Vector2.ZERO, size), bg)

	match theme:
		1:
			_draw_pantry(canvas, size, bg_dark, wood, accent)
		2:
			_draw_basement(canvas, size, bg_dark, wood, accent)
		3:
			_draw_kitchen(canvas, size, bg_dark, wood, accent)
		_:
			_draw_pantry(canvas, size, bg_dark, wood, accent)

static func _draw_pantry(canvas: CanvasItem, size: Vector2, bg_dark: Color, wood: Color, accent: Color) -> void:
	# Vertical wallpaper stripes
	var stripe_w := 60.0
	for x in range(0, int(size.x), int(stripe_w * 2)):
		canvas.draw_rect(Rect2(x, 0, stripe_w, size.y), bg_dark.lightened(0.08))

	# Top pantry shelves
	for shelf_y in [110.0, 210.0]:
		canvas.draw_rect(Rect2(0, shelf_y, size.x, 16), wood)
		canvas.draw_line(Vector2(0, shelf_y + 16), Vector2(size.x, shelf_y + 16), wood.darkened(0.4), 2.0)
		# Decorative jam jars on shelves
		for j_x in [120.0, 280.0, 600.0, 840.0, 1080.0]:
			canvas.draw_rect(Rect2(j_x, shelf_y - 28, 22, 28), accent)
			canvas.draw_circle(Vector2(j_x + 11, shelf_y - 28), 7.0, Color("fef08a"))

	# Countertop bottom board table
	var table_y := size.y * 0.42
	canvas.draw_rect(Rect2(0, table_y, size.x, size.y - table_y), wood.lightened(0.1))
	canvas.draw_line(Vector2(0, table_y), Vector2(size.x, table_y), wood.darkened(0.4), 4.0)

static func _draw_basement(canvas: CanvasItem, size: Vector2, bg_dark: Color, wood: Color, accent: Color) -> void:
	# Brick courses
	var row_h := 36.0
	var brick_w := 90.0
	for r in range(int(size.y / row_h) + 1):
		var y := r * row_h
		canvas.draw_line(Vector2(0, y), Vector2(size.x, y), bg_dark.darkened(0.3), 2.0)
		var offset := (r % 2) * (brick_w * 0.5)
		for c in range(-1, int(size.x / brick_w) + 2):
			var x := c * brick_w + offset
			canvas.draw_line(Vector2(x, y), Vector2(x, y + row_h), bg_dark.darkened(0.3), 2.0)

	# Dripping pipe across top
	canvas.draw_rect(Rect2(0, 40, size.x, 18), Color("334155"))
	canvas.draw_line(Vector2(0, 40), Vector2(size.x, 40), Color("64748b"), 2.0)
	# Pipe joints
	for px in [150.0, 450.0, 850.0, 1150.0]:
		canvas.draw_rect(Rect2(px, 36, 16, 26), Color("1e293b"))
		# Teal slime/water drip
		canvas.draw_circle(Vector2(px + 8, 70), 5.0, accent)

	# Dark cellar stone floor
	var floor_y := size.y * 0.44
	canvas.draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), wood.darkened(0.2))
	canvas.draw_line(Vector2(0, floor_y), Vector2(size.x, floor_y), Color("0f172a"), 4.0)

static func _draw_kitchen(canvas: CanvasItem, size: Vector2, bg_dark: Color, wood: Color, accent: Color) -> void:
	# Midnight sky background with circular moon window
	var window_center := Vector2(size.x * 0.82, 130.0)
	canvas.draw_circle(window_center, 70.0, Color("0f172a"))
	# Crescent moon glow
	canvas.draw_circle(window_center, 58.0, Color("fef08a"))
	canvas.draw_circle(window_center + Vector2(16, -8), 50.0, Color("0f172a"))
	# Window crossframe
	canvas.draw_line(window_center - Vector2(70, 0), window_center + Vector2(70, 0), wood, 4.0)
	canvas.draw_line(window_center - Vector2(0, 70), window_center + Vector2(0, 70), wood, 4.0)

	# Kitchen tile grid
	var tile_size := 50.0
	for tx in range(0, int(size.x), int(tile_size)):
		canvas.draw_line(Vector2(tx, 0), Vector2(tx, size.y * 0.45), bg_dark, 1.5)
	for ty in range(0, int(size.y * 0.45), int(tile_size)):
		canvas.draw_line(Vector2(0, ty), Vector2(size.x, ty), bg_dark, 1.5)

	# Midnight kitchen counter
	var counter_y := size.y * 0.42
	canvas.draw_rect(Rect2(0, counter_y, size.x, size.y - counter_y), wood)
	# Neon yellow accent trim
	canvas.draw_line(Vector2(0, counter_y), Vector2(size.x, counter_y), accent, 3.0)
