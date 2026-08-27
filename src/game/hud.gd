class_name HUD
extends CanvasLayer
## In-game heads-up display managing score, timers, combo meter, lives, popups and freeze overlay.

signal pause_requested()

@onready var _score_label: Label = $Root/TopBar/ScoreLabel if has_node("Root/TopBar/ScoreLabel") else null
@onready var _time_label: Label = $Root/TopBar/TimeLabel if has_node("Root/TopBar/TimeLabel") else null
@onready var _lives_display: LivesDisplay = $Root/TopBar/LivesDisplay if has_node("Root/TopBar/LivesDisplay") else null
@onready var _lives_label: Label = $Root/TopBar/LivesLabel if has_node("Root/TopBar/LivesLabel") else null
@onready var _combo_label: Label = $Root/BottomBar/ComboLabel if has_node("Root/BottomBar/ComboLabel") else null
@onready var _combo_bar: ProgressBar = $Root/BottomBar/ComboBar if has_node("Root/BottomBar/ComboBar") else null
@onready var _powerup_label: Label = $Root/TopBar/PowerupLabel if has_node("Root/TopBar/PowerupLabel") else null
@onready var _pause_button: Button = $Root/TopBar/PauseButton if has_node("Root/TopBar/PauseButton") else null
@onready var _popup_container: Control = $Root/PopupContainer if has_node("Root/PopupContainer") else null
@onready var _freeze_tint: ColorRect = $Root/FreezeTint if has_node("Root/FreezeTint") else null

var _displayed_score := 0
var _score_tween: Tween = null
var _last_mult := 1

func _ready() -> void:
	if _pause_button != null and not _pause_button.pressed.is_connected(_on_pause_pressed):
		_pause_button.pressed.connect(_on_pause_pressed)

	if is_inside_tree() and has_node("/root/Game"):
		var g: Node = get_node("/root/Game")
		if not g.score_changed.is_connected(set_score):
			g.score_changed.connect(set_score)
		if not g.combo_changed.is_connected(set_combo):
			g.combo_changed.connect(set_combo)
		if not g.lives_changed.is_connected(set_lives):
			g.lives_changed.connect(set_lives)
		if not g.time_left_changed.is_connected(set_time_left):
			g.time_left_changed.connect(set_time_left)
		if not g.powerup_started.is_connected(show_powerup):
			g.powerup_started.connect(show_powerup)
		set_score(g.score)
		set_combo(g.current_mult(), g.meter)
		set_lives(g.lives)
		if g.mode == "endless":
			set_wave(g.endless_wave())
		else:
			set_time_left(g.remaining_time())

func _on_pause_pressed() -> void:
	if is_inside_tree() and has_node("/root/AudioManager"):
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
	if mult > _last_mult:
		_on_combo_milestone(mult)
	_last_mult = mult

	if _combo_label != null:
		_combo_label.text = "COMBO x%d" % mult
		_combo_label.modulate = Color("ffd166") if mult > 1 else Color.WHITE
	if _combo_bar != null:
		_combo_bar.value = fill * 100.0

func _on_combo_milestone(mult: int) -> void:
	var callout := ""
	var sfx_name := ""
	match mult:
		2:
			callout = "NICE! x2"
			sfx_name = "combo_1"
		4:
			callout = "GREAT! x4"
			sfx_name = "combo_3"
		8:
			callout = "UNSTOPPABLE! x8"
			sfx_name = "combo_5"

	if sfx_name != "" and is_inside_tree() and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)

	if callout != "" and _popup_container != null:
		var l := Label.new()
		l.text = callout
		l.position = Vector2(640 - 100, 300)
		l.add_theme_font_size_override("font_size", 36)
		l.add_theme_color_override("font_color", Color("ffd166"))
		_popup_container.add_child(l)

		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(l, "scale", Vector2(1.3, 1.3), 0.15).from(Vector2(0.5, 0.5))
		tw.tween_property(l, "position:y", l.position.y - 40.0, 0.6)
		tw.tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.25)
		tw.chain().tween_callback(l.queue_free)

func set_lives(lives_count: int) -> void:
	if _lives_display != null:
		_lives_display.lives = lives_count
	elif _lives_label != null:
		var hearts := ""
		for i in range(3):
			hearts += "O " if i < lives_count else "X "
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
	if _powerup_label != null:
		var text := "FREEZE!" if kind == "freeze" else "2X POINTS!"
		_powerup_label.text = text
		_powerup_label.visible = true

	if kind == "freeze" and _freeze_tint != null:
		_freeze_tint.visible = true
	elif kind == "double" and _score_label != null:
		_score_label.modulate = Color("ffd166")

	var tw := create_tween()
	tw.tween_interval(dur)
	tw.tween_callback(func():
		if _powerup_label != null:
			_powerup_label.visible = false
		if kind == "freeze" and _freeze_tint != null:
			_freeze_tint.visible = false
		elif kind == "double" and _score_label != null:
			_score_label.modulate = Color.WHITE
	)

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
