class_name EndlessResults
extends Control
## Endless mode game-over screen with name submission and top-10 leaderboard display.

@onready var _score_lbl: Label = $VBox/ScoreLabel
@onready var _wave_lbl: Label = $VBox/WaveLabel
@onready var _name_entry_box: VBoxContainer = $VBox/NameEntryBox
@onready var _name_input: LineEdit = $VBox/NameEntryBox/HBox/NameInput
@onready var _submit_btn: Button = $VBox/NameEntryBox/HBox/SubmitBtn
@onready var _rank_lbl: Label = $VBox/RankLabel
@onready var _leaderboard_box: VBoxContainer = $VBox/LeaderboardBox
@onready var _leaderboard_list: VBoxContainer = $VBox/LeaderboardBox/Scroll/List
@onready var _play_again_btn: Button = $VBox/BtnBox/PlayAgainBtn
@onready var _menu_btn: Button = $VBox/BtnBox/MenuBtn

var _score := 0
var _best_combo := 0
var _submitted := false

func _ready() -> void:
	if has_node("/root/SceneRouter"):
		var args: Dictionary = get_node("/root/SceneRouter").current_args
		_score = int(args.get("score", 0))
		_best_combo = int(args.get("best_combo", 0))

	if _score_lbl != null:
		_score_lbl.text = "FINAL SCORE: %d" % _score

	if _wave_lbl != null:
		var wave := 1 + int(_score / 2000)
		_wave_lbl.text = "WAVE REACHED: %d  (BEST COMBO: %d)" % [wave, _best_combo]

	if _submit_btn != null:
		_submit_btn.pressed.connect(_on_submit)
	if _name_input != null:
		_name_input.text_submitted.connect(func(_t): _on_submit())
	if _play_again_btn != null:
		_play_again_btn.pressed.connect(_on_play_again)
	if _menu_btn != null:
		_menu_btn.pressed.connect(_on_menu)

	_render_leaderboard()

func _on_submit() -> void:
	if _submitted:
		return
	_submitted = true

	var player_name := "RAT"
	if _name_input != null and _name_input.text.strip_edges() != "":
		player_name = _name_input.text.strip_edges().to_upper().substr(0, 8)

	var rank := 0
	if has_node("/root/SaveManager"):
		rank = get_node("/root/SaveManager").submit_endless(player_name, _score)

	if _name_entry_box != null:
		_name_entry_box.visible = false

	if _rank_lbl != null:
		if rank > 0:
			_rank_lbl.text = "RANK #%d IN TOP 10!" % rank
			_rank_lbl.add_theme_color_override("font_color", Color("ffd166"))
		else:
			_rank_lbl.text = "Score recorded!"
		_rank_lbl.visible = true

	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("star_fanfare" if rank in [1, 2, 3] else "ui_click")

	_render_leaderboard()

func _render_leaderboard() -> void:
	if _leaderboard_list == null or not has_node("/root/SaveManager"):
		return

	for c in _leaderboard_list.get_children():
		c.queue_free()

	var entries: Array = get_node("/root/SaveManager").top_ten()
	if entries.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No records yet. Be the first!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_leaderboard_list.add_child(empty_lbl)
		return

	var rank := 1
	for e: Dictionary in entries:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 20)

		var rank_lbl := Label.new()
		rank_lbl.custom_minimum_size = Vector2(40, 0)
		rank_lbl.text = "#%d" % rank
		if rank == 1:
			rank_lbl.add_theme_color_override("font_color", Color("fbbf24")) # Gold
		elif rank == 2:
			rank_lbl.add_theme_color_override("font_color", Color("cbd5e1")) # Silver
		elif rank == 3:
			rank_lbl.add_theme_color_override("font_color", Color("d97706")) # Bronze
		row.add_child(rank_lbl)

		var name_lbl := Label.new()
		name_lbl.custom_minimum_size = Vector2(120, 0)
		name_lbl.text = str(e.get("name", "RAT"))
		row.add_child(name_lbl)

		var score_lbl := Label.new()
		score_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		score_lbl.text = "%d PTS" % int(e.get("score", 0))
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(score_lbl)

		_leaderboard_list.add_child(row)
		rank += 1

func _on_play_again() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"mode": "endless", "level_id": 0})

func _on_menu() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/screens/main_menu.tscn")
