class_name Board
extends Node2D
## Main interactive game board coordinating hole grid, spawn timing, mallet, juice FX and hit tests.

signal rat_bonked(id: String, points: int, pos: Vector2)
signal rat_escaped(id: String)
signal forbidden_hit(id: String)
signal whiffed()

var _cfg: LevelConfig = null
var _director: SpawnDirector = null
var _holes: Array[Hole] = []
var _theme: int = 1
var _hole_scene := preload("res://src/game/hole.tscn")
var _flying_rat_scene := preload("res://src/game/flying_rat.tscn")

var _flying_rat: FlyingRat = null
var _flying_spawn_timer: float = 0.0
var _flying_spawn_milestones: Array[float] = []
var _flying_spawn_index: int = 0
var _level_time_elapsed: float = 0.0

@onready var _backdrop: Node2D = $Backdrop if has_node("Backdrop") else null
@onready var _holes_container: Node2D = $Holes if has_node("Holes") else null
@onready var _fx: FxLayer = $FxLayer if has_node("FxLayer") else null
@onready var _mallet: Mallet = $Mallet if has_node("Mallet") else null

var _board_scale: float = 1.0

func _ready() -> void:
	if _backdrop == null and has_node("Backdrop"):
		_backdrop = $Backdrop
	if _holes_container == null and has_node("Holes"):
		_holes_container = $Holes
	if _fx == null and has_node("FxLayer"):
		_fx = $FxLayer
	if _mallet == null and has_node("Mallet"):
		_mallet = $Mallet

	if is_inside_tree():
		get_viewport().size_changed.connect(_reposition_holes)

func setup(level_cfg: LevelConfig, interval_fn: Callable = Callable()) -> void:
	_cfg = level_cfg
	_theme = _cfg.zone_theme if _cfg != null else 1
	_level_time_elapsed = 0.0
	_flying_spawn_timer = 0.0
	_flying_spawn_index = 0
	_flying_spawn_milestones.clear()

	if is_instance_valid(_flying_rat):
		_flying_rat.queue_free()
		_flying_rat = null

	if _cfg != null and _cfg.level_id >= 4:
		_flying_spawn_milestones.append(_cfg.duration_s * 0.35)
		if _cfg.duration_s >= 40.0:
			_flying_spawn_milestones.append(_cfg.duration_s * 0.70)

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

	for r in range(rows):
		for c in range(cols):
			var hole: Hole = _hole_scene.instantiate()
			hole.z_index = r * 10
			_holes_container.add_child(hole)
			hole.setup(_theme)
			_holes.append(hole)
			hole.rat_escaped.connect(func(rat): _on_rat_escaped(rat.rat_id))

	_reposition_holes()

	_director = SpawnDirector.new()
	_director.setup(-1)
	var weights := _cfg.rat_weights if _cfg != null else {"norm": 100}
	var max_conc := _cfg.max_concurrent if _cfg != null else 3
	_director.configure(_holes.size(), weights, max_conc)

	if interval_fn.is_valid():
		_director.set_interval_source(interval_fn)
	elif _cfg != null:
		_director.set_interval_source(_cfg.interval_at)

func _reposition_holes() -> void:
	if _cfg == null or _holes.is_empty():
		return
	var cols: int = _cfg.grid_columns if _cfg != null else 3
	var rows: int = _cfg.grid_rows if _cfg != null else 2
	var vp_size := get_viewport_rect().size if is_inside_tree() else Vector2(1280, 720)
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(1280, 720)

	var base_spacing_x := 180.0
	var base_spacing_y := 135.0
	var total_w := float(cols - 1) * base_spacing_x + 180.0
	var total_h := float(rows - 1) * base_spacing_y + 140.0

	var max_w := vp_size.x * 0.92
	var max_h := vp_size.y * 0.54
	var scale_w := max_w / total_w if total_w > max_w else 1.0
	var scale_h := max_h / total_h if total_h > max_h else 1.0
	_board_scale = minf(1.0, minf(scale_w, scale_h))

	var center_x := vp_size.x * 0.5
	var center_y := vp_size.y * 0.64
	var spacing_x := base_spacing_x * _board_scale
	var spacing_y := base_spacing_y * _board_scale
	var x0 := center_x - (float(cols - 1) * spacing_x * 0.5)
	var y0 := center_y - (float(rows - 1) * spacing_y * 0.5)

	var idx := 0
	for r in range(rows):
		for c in range(cols):
			if idx < _holes.size() and is_instance_valid(_holes[idx]):
				_holes[idx].position = Vector2(x0 + float(c) * spacing_x, y0 + float(r) * spacing_y)
				_holes[idx].scale = Vector2(_board_scale, _board_scale)
			idx += 1

	if _backdrop != null:
		_backdrop.queue_redraw()

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
			var h := _holes[res["hole"]]
			h.spawn_rat(res["rat"])
			if _fx != null:
				_fx.dirt_puff(h.position)

	tick_flying_rat_spawner(delta)

	if Game != null and Game.active():
		Game.tick(delta)

func has_flying_rat() -> bool:
	return is_instance_valid(_flying_rat) and _flying_rat.is_flying()

func spawn_flying_rat(start_pos: Vector2 = Vector2.ZERO, dir: Vector2 = Vector2.ZERO, spd: float = 380.0, p_type: String = "") -> FlyingRat:
	if is_instance_valid(_flying_rat) and _flying_rat.is_flying():
		return _flying_rat

	if is_instance_valid(_flying_rat):
		_flying_rat.queue_free()
		_flying_rat = null

	var frat: FlyingRat = _flying_rat_scene.instantiate()
	_flying_rat = frat
	add_child(frat)

	var vp_size := get_viewport_rect().size if is_inside_tree() else Vector2(1280, 720)
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(1280, 720)

	var final_pos := start_pos
	var final_dir := dir
	var final_spd := spd
	var final_ptype := p_type

	if final_pos == Vector2.ZERO:
		var left_to_right := randf() < 0.5
		var y_pos := randf_range(130.0, 190.0)
		if left_to_right:
			final_pos = Vector2(-80.0, y_pos)
			final_dir = Vector2.RIGHT
		else:
			final_pos = Vector2(vp_size.x + 80.0, y_pos)
			final_dir = Vector2.LEFT

	if final_dir == Vector2.ZERO:
		final_dir = Vector2.RIGHT if final_pos.x <= vp_size.x * 0.5 else Vector2.LEFT

	if final_ptype == "":
		final_ptype = "freeze" if randf() < 0.5 else "double"

	frat.launch(final_pos, final_dir, final_spd, final_ptype)
	return frat

func spawn_flying_rat_for_test(start_pos: Vector2 = Vector2(640, 180), dir: Vector2 = Vector2.RIGHT, spd: float = 380.0, p_type: String = "") -> FlyingRat:
	if is_instance_valid(_flying_rat):
		_flying_rat.queue_free()
		_flying_rat = null

	var frat: FlyingRat = _flying_rat_scene.instantiate()
	_flying_rat = frat
	add_child(frat)
	var pt := p_type if p_type != "" else ("freeze" if randf() < 0.5 else "double")
	frat.launch(start_pos, dir, spd, pt)
	return frat

func tick_flying_rat_spawner(delta: float) -> void:
	if _cfg == null:
		return

	var is_endless := (_cfg.level_id == 0) or (Game != null and Game.mode == "endless")

	if is_endless:
		_flying_spawn_timer += delta
		if _flying_spawn_timer >= 25.0:
			_flying_spawn_timer = 0.0
			if not has_flying_rat():
				spawn_flying_rat()
	elif _cfg.level_id >= 4:
		_level_time_elapsed += delta
		if _flying_spawn_index < _flying_spawn_milestones.size():
			if _level_time_elapsed >= _flying_spawn_milestones[_flying_spawn_index]:
				_flying_spawn_index += 1
				if not has_flying_rat():
					spawn_flying_rat()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		swing_at(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		swing_at(event.position)

func swing_at(pos: Vector2) -> void:
	if _mallet != null:
		_mallet.swing_at(pos)

	if is_instance_valid(_flying_rat) and _flying_rat.can_be_hit():
		var hit_radius: float = _flying_rat.hit_radius if _flying_rat.hit_radius > 0.0 else 65.0
		if pos.distance_to(_flying_rat.global_position) <= hit_radius:
			var hit_pos := _flying_rat.global_position
			var p_type := _flying_rat.powerup_type
			_flying_rat.strike()
			
			if Game != null and Game.active():
				Game.score += 1000
				Game.score_changed.emit(Game.score)
				if p_type == "freeze":
					Game.trigger_powerup("freeze", Game.FREEZE_SECONDS)
				else:
					Game.trigger_powerup("double", Game.DOUBLE_SECONDS)
			
			if _fx != null:
				_fx.confetti(hit_pos)
				_fx.impact(hit_pos, true)
				_fx.shockwave(hit_pos, Color("fbbf24"))
				_fx.shake(4.0)
			
			if is_inside_tree() and has_node("/root/AudioManager"):
				var am: Node = get_node("/root/AudioManager")
				am.play_sfx("star_pickup")
				am.play_sfx("bonk")
			
			rat_bonked.emit("flying", 1000, hit_pos)
			return

	var cands: Array = []
	for i in range(_holes.size()):
		var h := _holes[i]
		if is_instance_valid(h) and h.occupied():
			cands.append({"pos": h.rat_head_global_pos(), "hole": h, "index": i})

	var pick_idx := HitTest.pick(pos, 78.0 * _board_scale, cands)
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
				if is_inside_tree() and has_node("/root/AudioManager"):
					var am: Node = get_node("/root/AudioManager")
					if id == "tank":
						am.play_sfx("bonk_heavy")
					else:
						am.play_sfx("bonk")
				if _fx != null:
					_fx.impact(target_hole.rat_head_global_pos(), id == "tank" or id == "golden")
					_fx.shake(2.0 if id != "tank" else 5.0)
					if id == "tank":
						_fx.hit_stop(0.06)
				rat_bonked.emit(id, pts, target_hole.rat_head_global_pos())
			"staggered":
				if is_inside_tree() and has_node("/root/AudioManager"):
					get_node("/root/AudioManager").play_sfx("bonk_heavy")
				if _fx != null:
					_fx.impact(target_hole.rat_head_global_pos(), false)
					_fx.shake(3.0)
			"forbidden":
				var id := target_hole.rat_id()
				if is_inside_tree() and has_node("/root/AudioManager"):
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
					if id == "boom":
						_fx.hit_stop(0.08)
				forbidden_hit.emit(id)
			_:
				_trigger_whiff()

func _trigger_whiff() -> void:
	if is_inside_tree() and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("whiff")
	if Game != null and Game.active():
		Game.on_whiff()
	whiffed.emit()

func _on_rat_escaped(id: String) -> void:
	if Game != null and Game.active():
		Game.on_rat_escaped(id)
	rat_escaped.emit(id)
