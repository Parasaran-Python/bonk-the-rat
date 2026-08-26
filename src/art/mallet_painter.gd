class_name MalletPainter
extends RefCounted
## Procedural painter for the player's mallet / hammer.

static func draw_mallet(canvas: CanvasItem) -> void:
	# Wooden handle extending downwards from head
	var handle_col := Color("854d0e")
	var handle_pts := PackedVector2Array([
		Vector2(-6, -10), Vector2(6, -10),
		Vector2(5, 60), Vector2(-5, 60)
	])
	canvas.draw_colored_polygon(handle_pts, handle_col)
	canvas.draw_polyline(handle_pts, Color("451a03"), 2.0)
	# Handle grip rings
	for y in [25.0, 35.0, 45.0]:
		canvas.draw_line(Vector2(-5, y), Vector2(5, y), Color("fde047"), 2.0)

	# Red mallet head
	var head_rect := Rect2(-34, -36, 68, 32)
	canvas.draw_rect(head_rect, Color("dc2626"))
	# Cream center band
	canvas.draw_rect(Rect2(-10, -36, 20, 32), Color("fef3c7"))
	# Head outline and bevels
	canvas.draw_rect(head_rect, Color("991b1b"), false, 2.5)
	# Soft highlight on top edge
	canvas.draw_line(Vector2(-32, -34), Vector2(32, -34), Color(1.0, 1.0, 1.0, 0.4), 2.0)
	# Impact face caps
	canvas.draw_line(Vector2(-34, -36), Vector2(-34, -4), Color("b91c1c"), 3.0)
	canvas.draw_line(Vector2(34, -36), Vector2(34, -4), Color("b91c1c"), 3.0)
