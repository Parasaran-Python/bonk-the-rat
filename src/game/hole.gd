class_name Hole
extends Node2D
## Hole container managing hole drawing layers and child Rat actor lifecycle.

signal rat_bonked(rat: Rat)
signal rat_escaped(rat: Rat)
signal forbidden_struck(id: String)

var theme: int = 1
@onready var _rat: Rat = $Rat if has_node("Rat") else null
@onready var _bg: Node2D = $HoleBg if has_node("HoleBg") else null
@onready var _rim: Node2D = $RimFront if has_node("RimFront") else null

func _ready() -> void:
	if _rat == null and has_node("Rat"):
		_rat = $Rat
	if _rat != null:
		if not _rat.bonked.is_connected(_on_rat_bonked):
			_rat.bonked.connect(_on_rat_bonked)
		if not _rat.escaped.is_connected(_on_rat_escaped):
			_rat.escaped.connect(_on_rat_escaped)

func setup(p_theme: int) -> void:
	theme = p_theme
	if _bg != null:
		_bg.queue_redraw()
	if _rim != null:
		_rim.queue_redraw()

func occupied() -> bool:
	if _rat == null:
		return false
	return _rat.state in [Rat.State.RISING, Rat.State.UP, Rat.State.SINKING]

func spawn_rat(id: String, speed_scale: float = 1.0) -> void:
	if _rat != null:
		_rat.pop_up(id, speed_scale)

func try_strike() -> String:
	if not occupied():
		return "miss"

	if RatTypes.is_forbidden(_rat.rat_id):
		var fid := _rat.rat_id
		_rat.flee_early()
		forbidden_struck.emit(fid)
		return "forbidden"

	var hp_rem := _rat.strike()
	if hp_rem <= 0:
		return "bonked"
	else:
		return "staggered"

func rat_head_global_pos() -> Vector2:
	return global_position + Vector2(0, -40)

func rat_id() -> String:
	return _rat.rat_id if _rat != null else ""

func _on_rat_bonked(r: Rat) -> void:
	rat_bonked.emit(r)

func _on_rat_escaped(r: Rat) -> void:
	rat_escaped.emit(r)
