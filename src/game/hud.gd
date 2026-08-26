class_name HUD
extends CanvasLayer
## In-game heads-up display managing score, timers, combo meter, lives and floating popups.

signal pause_requested()

@onready var _score_label: Label = $Root/TopBar/ScoreLabel
@onready var _time_label: Label = $Root/TopBar/TimeLabel
@onready var _lives_label: Label = $Root/TopBar/LivesLabel
@onready var _combo_label: Label = $Root/BottomBar/ComboLabel
@onready var _combo_bar: ProgressBar = $Root/BottomBar/ComboBar
@onready var _powerup_label: Label = $Root/TopBar/PowerupLabel
@onready var _pause_button: Button = $Root/TopBar/PauseButton
@onready var _popup_container: Control = $Root/PopupContainer

var _displayed_score := 0
var _score_tween: Tween = null

func _ready() -> void:
	if _pause_button != null:
		_pause_button.pressed.connect(_on_pause_pressed)

	if has_node("/root/Game"):
		var g: Node = get_node("/root/Game")
		g.score_changed.connect(set_score)
		g.combo_changed.connect(set_combo)
		g.lives_changed.connect(set_lives)
		g.time_left_changed.connect(set_time_left)
		g.powerup_started.connect(show_powerup)
		set_score(g.score)
		set_combo(g.current_mult(), g.meter)
		set_lives(g.lives)
		if g.mode == "endless":
			set_wave(g.endless_wave())
		else:
			set_time_left(g.remaining_time())

func _on_pause_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	pause_requested.emit()

func set_score(val: int) -> void:
	if _score_tween != null and _score_tween.is_valid():
		_score_tween.kill()

	_score_tween = create_tween()
	_score_tween.tween_method(func(v: int):
		_displayed_score = v
		if _score_label != null:
			_score_label.text = "SCORE: %d" % v
	, _displayed_score, val, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func set_combo(mult: int, fill: float) -> void:
	if _combo_label != null:
		_combo_label.text = "COMBO x%d" % mult
		_combo_label.modulate = Color("ffd166") if mult > 1 else Color.WHITE
	if _combo_bar != null:
		_combo_bar.value = fill * 100.0

func set_lives(lives_count: int) -> void:
	if _lives_label != null:
		var hearts := ""
		for i in range(3):
			hearts += "❤️ " if i < lives_count else "🖤 "
		_lives_label.text = hearts.strip_edges()

func set_time_left(sec: float) -> void:
	if _time_label != null:
		var total_s := int(ceilf(sec))
		var mins := total_s / 60
		var s := total_s % 60
		_time_label.text = "TIME: %02d:%02d" % [mins, s]

func set_wave(wave: int) -> void:
	if _time_label != null:
		_time_label.text = "WAVE: %d" % wave

func show_powerup(kind: String, dur: float) -> void:
	if _powerup_label == null:
		return
	var text := "⚡ FREEZE!" if kind == "freeze" else "⭐ 2X POINTS!"
	_powerup_label.text = text
	_powerup_label.visible = true
	var tw := create_tween()
	tw.tween_interval(dur)
	tw.tween_callback(func(): _powerup_label.visible = false)

func show_score_popup(pts: int, pos: Vector2) -> void:
	if _popup_container == null:
		return
	var l := Label.new()
	l.text = "+%d" % pts
	l.position = pos + Vector2(-20, -30)
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color("fef08a"))
	_popup_container.add_child(l)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 40.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.55).set_delay(0.2)
	tw.chain().tween_callback(l.queue_free)
