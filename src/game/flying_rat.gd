class_name FlyingRat
extends Node2D
## Autonomous airborne glider rat actor with sine-wave trajectory and mid-air bonk handling.

enum State {
	INACTIVE,
	FLYING,
	BONKED,
	ESCAPED,
	GONE,
}

signal bonked(pos: Vector2, powerup_type: String)
signal escaped(rat: FlyingRat)
signal despawned(rat: FlyingRat)

var state: State = State.INACTIVE
var base_y: float = 160.0
var direction: Vector2 = Vector2.RIGHT
var speed: float = 380.0
var flight_time: float = 0.0
var powerup_type: String = "freeze"
var hit_radius: float = 65.0

var _tween: Tween = null
@onready var _visual: Node2D = $Visual if has_node("Visual") else null

func _ready() -> void:
	z_index = 200
	if _visual == null and has_node("Visual"):
		_visual = $Visual

func _draw() -> void:
	if not has_node("Visual"):
		RatPainter.draw_flying_rat(self, flight_time, state == State.BONKED)

func _process(delta: float) -> void:
	if state == State.FLYING:
		tick(delta)

func launch(start_pos: Vector2, dir: Vector2 = Vector2.RIGHT, spd: float = 380.0, p_type: String = "") -> void:
	position = start_pos
	base_y = start_pos.y
	direction = dir.normalized() if dir.length_squared() > 0.0 else Vector2.RIGHT
	speed = spd
	flight_time = 0.0
	state = State.FLYING
	rotation = 0.0
	modulate = Color.WHITE
	visible = true
	z_index = 200

	if p_type != "":
		powerup_type = p_type
	else:
		powerup_type = "freeze" if randf() < 0.5 else "star"

	if _visual != null:
		_visual.queue_redraw()
	queue_redraw()

func is_flying() -> bool:
	return state == State.FLYING

func can_be_hit() -> bool:
	return state == State.FLYING

func tick(delta: float) -> void:
	if state != State.FLYING:
		return

	flight_time += delta
	position.x += direction.x * speed * delta
	position.y = base_y + sin(flight_time * 4.0) * 28.0

	# Check off-screen exit bounds
	if (direction.x > 0.0 and position.x > 1380.0) or (direction.x < 0.0 and position.x < -100.0) or (direction.x == 0.0 and flight_time > 10.0):
		_on_escaped()
		return

	if _visual != null:
		_visual.queue_redraw()
	queue_redraw()

func _on_escaped() -> void:
	if state != State.FLYING:
		return
	state = State.ESCAPED
	visible = false
	escaped.emit(self)
	despawned.emit(self)
	queue_free()

func strike() -> String:
	if not can_be_hit():
		return ""

	state = State.BONKED
	bonked.emit(global_position, powerup_type)
	_play_tumble_exit()
	return "bonked"

func _play_tumble_exit() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	if _visual != null:
		_visual.queue_redraw()
	queue_redraw()

	_tween = create_tween()
	_tween.set_parallel(true)
	var tumble_dir: float = 1.0 if direction.x >= 0.0 else -1.0
	_tween.tween_property(self, "rotation", rotation + tumble_dir * TAU * 1.5, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", position.y + 350.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:x", position.x + direction.x * speed * 0.3, 0.45)
	_tween.tween_property(self, "modulate:a", 0.0, 0.40).set_delay(0.05)
	_tween.chain().tween_callback(func():
		state = State.GONE
		visible = false
		despawned.emit(self)
		queue_free()
	)
