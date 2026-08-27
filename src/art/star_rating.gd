class_name StarRating
extends Control
## Procedural vector star rating display (0 to 3 stars).

@export var stars: int = 0:
	set(v):
		stars = clampi(v, 0, max_stars)
		queue_redraw()

@export var max_stars: int = 3:
	set(v):
		max_stars = maxi(1, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

@export var star_size: float = 24.0:
	set(v):
		star_size = maxf(4.0, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

@export var spacing: float = 8.0:
	set(v):
		spacing = maxf(0.0, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

@export var alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER:
	set(v):
		alignment = v
		queue_redraw()

func _init(p_stars: int = 0, p_size: float = 24.0, p_spacing: float = 8.0) -> void:
	stars = p_stars
	star_size = p_size
	spacing = p_spacing
	custom_minimum_size = _calculate_min_size()

func _ready() -> void:
	custom_minimum_size = _calculate_min_size()

func _calculate_min_size() -> Vector2:
	var total_w := float(max_stars) * (star_size * 2.0) + float(max_stars - 1) * spacing
	var total_h := star_size * 2.0
	return Vector2(total_w, total_h)

func _draw() -> void:
	var total_w := float(max_stars) * (star_size * 2.0) + float(max_stars - 1) * spacing
	var start_x := 0.0
	match alignment:
		HORIZONTAL_ALIGNMENT_CENTER:
			start_x = (size.x - total_w) * 0.5
		HORIZONTAL_ALIGNMENT_RIGHT:
			start_x = size.x - total_w
		_:
			start_x = 0.0

	var center_y := size.y * 0.5

	for i in range(max_stars):
		var center_x := start_x + float(i) * (star_size * 2.0 + spacing) + star_size
		var is_filled := i < stars
		UiPainter.draw_star(self, Vector2(center_x, center_y), star_size, is_filled)
