class_name Board
extends Node2D
## Main interactive game board coordinating hole grid, spawn timing, mallet and hit tests.

signal rat_bonked(id: String, points: int, pos: Vector2)
signal rat_escaped(id: String)
signal forbidden_hit(id: String)
signal whiffed()

var _cfg: LevelConfig = null
var _director: SpawnDirector = null
var _holes: Array[Hole] = []
var _theme: int = 1
var _hole_scene := preload("res://src/game/hole.tscn")

@onready var _backdrop: Node2D = $Backdrop if has_node("Backdrop") else null
@onready var _holes_container: Node2D = $Holes if has_node("Holes") else null
@onready var _fx: FxLayer = $FxLayer if has_node("FxLayer") else null
@onready var _mallet: Mallet = $Mallet if has_node("Mallet") else null

func _ready() -> void:
	if _backdrop == null and has_node("Backdrop"):
		_backdrop = $Backdrop
	if _holes_container == null and has_node("Holes"):
		_holes_container = $Holes
	if _fx == null and has_node("FxLayer"):
		_fx = $FxLayer
	if _mallet == null and has_node("Mallet"):
		_mallet = $Mallet

func setup(level_cfg: LevelConfig, interval_fn: Callable = Callable()) -> void:
	_cfg = level_cfg
	_theme = _cfg.zone_theme if _cfg != null else 1

	if _backdrop != null:
		_backdrop.queue_redraw()

	if _holes_container == null:
		_holes_container = Node2D.new()
		_holes_container.name = "Holes"
		add_child(_holes_container)

	for h in _holes:
		if is_instance_valid(h):
			h.queue_free()
	_holes.clear()

	var cols: int = _cfg.grid_columns if _cfg != null else 3
	var rows: int = _cfg.grid_rows if _cfg != null else 2
	var spacing_x := 190.0
	var spacing_y := 140.0
	var x0 := 640.0 - (float(cols - 1) * spacing_x * 0.5)
	var y0 := 460.0 - (float(rows - 1) * spacing_y * 0.5)

	for r in range(rows):
		for c in range(cols):
			var hole: Hole = _hole_scene.instantiate()
			hole.position = Vector2(x0 + float(c) * spacing_x, y0 + float(r) * spacing_y)
			hole.z_index = r * 10
			_holes_container.add_child(hole)
			hole.setup(_theme)
			_holes.append(hole)
			hole.rat_escaped.connect(func(rat): _on_rat_escaped(rat.rat_id))

	_director = SpawnDirector.new()
	_director.setup(-1)
	var weights := _cfg.rat_weights if _cfg != null else {"norm": 100}
	var max_conc := _cfg.max_concurrent if _cfg != null else 3
	_director.configure(_holes.size(), weights, max_conc)

	if interval_fn.is_valid():
		_director.set_interval_source(interval_fn)
	elif _cfg != null:
		_director.set_interval_source(_cfg.interval_at)

func _active_rats_count() -> int:
	var c := 0
	for h in _holes:
		if is_instance_valid(h) and h.occupied():
			c += 1
	return c

func _process(delta: float) -> void:
	if _director != null and _cfg != null:
		var progress := 0.0
		if Game.mode == "campaign":
			progress = 1.0 - (Game.remaining_time() / maxf(1.0, _cfg.duration_s))
		var now_ms := Time.get_ticks_msec()
		var res := _director.tick(delta, _active_rats_count(), progress, now_ms)
		if res.has("hole") and res["hole"] >= 0 and res["hole"] < _holes.size():
			_holes[res["hole"]].spawn_rat(res["rat"])

	if Game != null and Game.active():
		Game.tick(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		swing_at(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		swing_at(event.position)

func swing_at(pos: Vector2) -> void:
	if _mallet != null:
		_mallet.swing_at(pos)

	var cands: Array = []
	for i in range(_holes.size()):
		var h := _holes[i]
		if is_instance_valid(h) and h.occupied():
			cands.append({"pos": h.rat_head_global_pos(), "hole": h, "index": i})

	var pick_idx := HitTest.pick(pos, 78.0, cands)
	if pick_idx == -1:
		_trigger_whiff()
	else:
		var target_cand: Dictionary = cands[pick_idx]
		var target_hole: Hole = target_cand["hole"]
		var strike_res := target_hole.try_strike()
		match strike_res:
			"bonked":
				var id := target_hole.rat_id()
				var pts := 0
				if Game != null and Game.active():
					pts = Game.on_rat_bonked(id)
				if has_node("/root/AudioManager"):
					var am: Node = get_node("/root/AudioManager")
					if id == "tank":
						am.play_sfx("bonk_heavy")
					else:
						am.play_sfx("bonk")
				if _fx != null:
					_fx.impact(target_hole.rat_head_global_pos(), id == "tank" or id == "golden")
					_fx.shake(2.0 if id != "tank" else 5.0)
				rat_bonked.emit(id, pts, target_hole.rat_head_global_pos())
			"staggered":
				if has_node("/root/AudioManager"):
					get_node("/root/AudioManager").play_sfx("bonk_heavy")
				if _fx != null:
					_fx.impact(target_hole.rat_head_global_pos(), false)
					_fx.shake(3.0)
			"forbidden":
				var id := target_hole.rat_id()
				if has_node("/root/AudioManager"):
					var am: Node = get_node("/root/AudioManager")
					if id == "boom":
						am.play_sfx("boom")
					else:
						am.play_sfx("yowl")
				if Game != null and Game.active():
					Game.on_forbidden_hit()
				if _fx != null:
					_fx.impact(target_hole.rat_head_global_pos(), true)
					_fx.shake(6.0 if id != "boom" else 10.0)
				forbidden_hit.emit(id)
			_:
				_trigger_whiff()

func _trigger_whiff() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("whiff")
	if Game != null and Game.active():
		Game.on_whiff()
	whiffed.emit()

func _on_rat_escaped(id: String) -> void:
	if Game != null and Game.active():
		Game.on_rat_escaped(id)
	rat_escaped.emit(id)
