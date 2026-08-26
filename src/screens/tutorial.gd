class_name TutorialScreen
extends Node2D
## Interactive first-launch tutorial introducing basic rat bonking and cat avoidance.

@onready var _board: Board = $Board if has_node("Board") else null
@onready var _instruction_lbl: Label = $UI/Banner/VBox/InstructionLabel if has_node("UI/Banner/VBox/InstructionLabel") else null
@onready var _hint_lbl: Label = $UI/Banner/VBox/HintLabel if has_node("UI/Banner/VBox/HintLabel") else null
@onready var _skip_btn: Button = $UI/SkipBtn if has_node("UI/SkipBtn") else null

var _phase := 1
var _p1_hits := 0
var _p2_success := false

func _ready() -> void:
	if _skip_btn != null:
		_skip_btn.pressed.connect(_on_skip_pressed)

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_music("zone1")

	_start_phase_1()

func _start_phase_1() -> void:
	_phase = 1
	_p1_hits = 0
	if _instruction_lbl != null:
		_instruction_lbl.text = "PHASE 1: BONK 3 RATS! (0/3)"
	if _hint_lbl != null:
		_hint_lbl.text = "Click or tap the rats before they sink away!"

	if _board != null:
		var cfg := LevelConfig.new()
		cfg.level_id = 1
		cfg.duration_s = 99999.0
		cfg.grid_columns = 3
		cfg.grid_rows = 2
		cfg.max_concurrent = 2
		cfg.spawn_interval_start = 1.1
		cfg.spawn_interval_end = 1.1
		cfg.rat_weights = {"norm": 100}
		cfg.zone_theme = 1

		if has_node("/root/Game"):
			get_node("/root/Game").start_level(cfg)

		_board.setup(cfg, cfg.interval_at)
		if not _board.rat_bonked.is_connected(_on_p1_bonked):
			_board.rat_bonked.connect(_on_p1_bonked)

func _on_p1_bonked(id: String, _pts: int, _pos: Vector2) -> void:
	if _phase != 1:
		return
	if id == "norm":
		_p1_hits += 1
		if _instruction_lbl != null:
			_instruction_lbl.text = "PHASE 1: BONK 3 RATS! (%d/3)" % _p1_hits
		if _p1_hits >= 3:
			_start_phase_2()

func _start_phase_2() -> void:
	_phase = 2
	_p2_success = false
	if _instruction_lbl != null:
		_instruction_lbl.text = "PHASE 2: WHISKERS THE CAT — DON'T BONK!"
	if _hint_lbl != null:
		_hint_lbl.text = "Let the cat sink safely! Hitting cats costs a life!"

	if _board != null:
		var cfg := LevelConfig.new()
		cfg.level_id = 1
		cfg.duration_s = 99999.0
		cfg.grid_columns = 3
		cfg.grid_rows = 2
		cfg.max_concurrent = 1
		cfg.spawn_interval_start = 1.5
		cfg.spawn_interval_end = 1.5
		cfg.rat_weights = {"whiskers": 100}
		cfg.zone_theme = 1

		_board.setup(cfg, cfg.interval_at)
		if not _board.forbidden_hit.is_connected(_on_p2_cat_hit):
			_board.forbidden_hit.connect(_on_p2_cat_hit)
		if not _board.rat_escaped.is_connected(_on_p2_cat_escaped):
			_board.rat_escaped.connect(_on_p2_cat_escaped)

func _on_p2_cat_hit(_id: String) -> void:
	if _phase != 2 or _p2_success:
		return
	if _instruction_lbl != null:
		_instruction_lbl.text = "OUCH! DON'T BONK THE CAT!"
	if _hint_lbl != null:
		_hint_lbl.text = "Try again! Wait for the cat to sink on its own."
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(_start_phase_2)

func _on_p2_cat_escaped(_id: String) -> void:
	if _phase != 2 or _p2_success:
		return
	_p2_success = true
	if _instruction_lbl != null:
		_instruction_lbl.text = "PERFECT! YOU'RE READY TO PLAY!"
	if _hint_lbl != null:
		_hint_lbl.text = "Entering Zone Map..."

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("star_fanfare")

	var tw := create_tween()
	tw.tween_interval(1.2)
	tw.tween_callback(_finish_tutorial)

func _finish_tutorial() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").mark_tutorial_seen()
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/zone_map.tscn")

func _on_skip_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	_finish_tutorial()
