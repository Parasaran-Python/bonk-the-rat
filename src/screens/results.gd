class_name Results
extends Control
## Results screen celebrating level completion with star reveals and next-level routing.

@onready var _title_lbl: Label = $VBox/Title
@onready var _stars_lbl: Label = $VBox/StarsLabel
@onready var _score_lbl: Label = $VBox/ScoreLabel
@onready var _best_lbl: Label = $VBox/BestLabel
@onready var _combo_lbl: Label = $VBox/ComboLabel
@onready var _retry_btn: Button = $VBox/BtnBox/RetryBtn
@onready var _next_btn: Button = $VBox/BtnBox/NextBtn
@onready var _map_btn: Button = $VBox/BtnBox/MapBtn

var _result: Dictionary = {}
var _level_id := 1

func _ready() -> void:
	if has_node("/root/SceneRouter"):
		_result = get_node("/root/SceneRouter").current_args

	var won: bool = bool(_result.get("won", false))
	var score: int = int(_result.get("score", 0))
	var stars: int = int(_result.get("stars", 0))
	var best_combo: int = int(_result.get("best_combo", 0))
	var mode: String = str(_result.get("mode", "campaign"))

	if has_node("/root/Game") and get_node("/root/Game").cfg != null:
		_level_id = get_node("/root/Game").cfg.level_id

	if _retry_btn != null:
		_retry_btn.pressed.connect(_on_retry)
	if _next_btn != null:
		_next_btn.pressed.connect(_on_next)
	if _map_btn != null:
		_map_btn.pressed.connect(_on_map)

	if _title_lbl != null:
		if won:
			_title_lbl.text = "LEVEL COMPLETE!"
			_title_lbl.add_theme_color_override("font_color", Color("ffd166"))
		else:
			_title_lbl.text = "LEVEL FAILED"
			_title_lbl.add_theme_color_override("font_color", Color("ef4444"))

	if _stars_lbl != null:
		var s_text := ""
		for s in range(3):
			s_text += "⭐ " if s < stars else "☆ "
		_stars_lbl.text = s_text.strip_edges()

	if _score_lbl != null:
		_score_lbl.text = "SCORE: %d" % score

	if _combo_lbl != null:
		_combo_lbl.text = "BEST COMBO: %d HITS" % best_combo

	var prev_best := 0
	if has_node("/root/SaveManager") and _level_id > 0:
		prev_best = get_node("/root/SaveManager").get_best(_level_id)

	if _best_lbl != null:
		if score >= prev_best and score > 0:
			_best_lbl.text = "🎉 NEW BEST SCORE! 🎉"
			_best_lbl.visible = true
		elif prev_best > 0:
			_best_lbl.text = "BEST: %d" % prev_best
			_best_lbl.visible = true
		else:
			_best_lbl.visible = false

	var next_id := Progression.next_level_id(_level_id)
	if _next_btn != null:
		_next_btn.visible = won and next_id != -1 and mode == "campaign"

	if stars > 0 and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("star_fanfare")

func _on_retry() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"level_id": _level_id})

func _on_next() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	var next_id := Progression.next_level_id(_level_id)
	if next_id != -1 and has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"level_id": next_id})

func _on_map() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/zone_map.tscn")
