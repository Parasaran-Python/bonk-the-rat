class_name Rat
extends Node2D
## Rat actor state machine managing popup tweens, strikes and procedural rendering.

enum State {
	RISING,
	UP,
	SINKING,
	HIT,
	FLEEING,
	GONE,
}

signal bonked(rat: Rat)
signal escaped(rat: Rat)
signal despawned(rat: Rat)

const DOWN_OFFSET := 130.0

var state: State = State.GONE
var rat_id: String = "norm"
var hp_left: int = 1
var _squash := Vector2.ONE
var _tween: Tween = null
@onready var _visual: Node2D = $Visual if has_node("Visual") else null

func _ready() -> void:
	if _visual == null and has_node("Visual"):
		_visual = $Visual

static func can_transition(from: State, to: State) -> bool:
	if from == State.GONE:
		return false
	if from == State.HIT:
		return to == State.GONE
	if to == State.HIT:
		return from in [State.RISING, State.UP, State.SINKING]
	if to == State.FLEEING:
		return from in [State.RISING, State.UP]
	if from == State.RISING and to == State.UP:
		return true
	if from == State.UP and to == State.SINKING:
		return true
	if from == State.SINKING and to == State.GONE:
		return true
	if from == State.FLEEING and to == State.GONE:
		return true
	return false

func scale_visual() -> Vector2:
	return _squash

func _process(_delta: float) -> void:
	if _visual != null and visible and state != State.GONE:
		_visual.queue_redraw()

func pop_up(id: String, speed_scale: float = 1.0) -> void:
	rat_id = id
	var type_info := RatTypes.get_type(id)
	hp_left = int(type_info.get("hp", 1))
	state = State.RISING
	_squash = Vector2.ONE
	position.y = DOWN_OFFSET
	visible = true

	if _visual != null:
		_visual.queue_redraw()

	var rise_t: float = float(type_info.get("rise", 0.30)) / maxf(0.1, speed_scale)
	var up_t: float = float(type_info.get("up", 1.00)) / maxf(0.1, speed_scale)
	var sink_t: float = float(type_info.get("sink", 0.22)) / maxf(0.1, speed_scale)

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(false)
	_tween.tween_property(self, "position:y", 0.0, rise_t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(func(): _on_reached_up(up_t, sink_t))

func _on_reached_up(up_t: float, sink_t: float) -> void:
	if state != State.RISING:
		return
	state = State.UP

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_interval(up_t)
	_tween.tween_callback(func(): _start_sinking(sink_t))

func _start_sinking(sink_t: float) -> void:
	if state != State.UP:
		return
	state = State.SINKING

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "position:y", DOWN_OFFSET, sink_t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_on_sunk_away)

func _on_sunk_away() -> void:
	if state == State.SINKING:
		state = State.GONE
		visible = false
		escaped.emit(self)
		despawned.emit(self)

func strike() -> int:
	if not can_transition(state, State.HIT):
		return hp_left

	hp_left -= 1
	if hp_left <= 0:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		state = State.HIT
		bonked.emit(self)
		_play_hit_death_tween()
		return 0
	else:
		_play_stagger_tween()
		return hp_left

func _play_hit_death_tween() -> void:
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "_squash", Vector2(1.4, 0.4), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:y", DOWN_OFFSET, 0.14).set_delay(0.04)
	_tween.chain().tween_callback(func():
		state = State.GONE
		visible = false
		despawned.emit(self)
	)

func _play_stagger_tween() -> void:
	var tw := create_tween()
	tw.tween_property(self, "_squash", Vector2(1.25, 0.75), 0.05)
	tw.tween_property(self, "_squash", Vector2(0.9, 1.1), 0.05)
	tw.tween_property(self, "_squash", Vector2.ONE, 0.05)

func flee_early() -> void:
	if not can_transition(state, State.FLEEING):
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	state = State.FLEEING
	_tween = create_tween()
	_tween.tween_property(self, "position:y", DOWN_OFFSET, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func():
		state = State.GONE
		visible = false
		escaped.emit(self)
		despawned.emit(self)
	)
