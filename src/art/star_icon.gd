class_name StarIcon
extends Control
## A single procedural vector star icon.

@export var radius: float = 14.0:
	set(v):
		radius = v
		custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
		queue_redraw()

@export var color: Color = Color("ffd166"):
	set(v):
		color = v
		queue_redraw()

func _init(p_radius: float = 14.0, p_color: Color = Color("ffd166")) -> void:
	radius = p_radius
	color = p_color
	custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)

func _ready() -> void:
	custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)

func _draw() -> void:
	UiPainter.draw_star(self, size * 0.5, radius, true, color)
