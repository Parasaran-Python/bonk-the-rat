class_name LivesDisplay
extends Control
## Procedural vector heart lives indicator (0 to 3 hearts).

@export var lives: int = 3:
	set(v):
		lives = clampi(v, 0, max_lives)
		queue_redraw()

@export var max_lives: int = 3:
	set(v):
		max_lives = maxi(1, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

@export var heart_size: float = 24.0:
	set(v):
		heart_size = maxf(4.0, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

@export var spacing: float = 8.0:
	set(v):
		spacing = maxf(0.0, v)
		custom_minimum_size = _calculate_min_size()
		queue_redraw()

func _init(p_lives: int = 3, p_size: float = 24.0) -> void:
	lives = p_lives
	heart_size = p_size
	custom_minimum_size = _calculate_min_size()

func _ready() -> void:
	custom_minimum_size = _calculate_min_size()

func _calculate_min_size() -> Vector2:
	var total_w := float(max_lives) * (heart_size * 1.8) + float(max_lives - 1) * spacing
	var total_h := heart_size * 1.8
	return Vector2(total_w, total_h)

func _draw() -> void:
	var total_w := float(max_lives) * (heart_size * 1.8) + float(max_lives - 1) * spacing
	var start_x := (size.x - total_w) * 0.5
	var center_y := size.y * 0.5

	for i in range(max_lives):
		var center_x := start_x + float(i) * (heart_size * 1.8 + spacing) + heart_size * 0.9
		var is_active := i < lives
		UiPainter.draw_heart(self, Vector2(center_x, center_y), heart_size, is_active)
