class_name GameScreen
extends Node2D
## Primary gameplay screen orchestrating Board, HUD and Pause Overlay.

@onready var _board: Board = $Board if has_node("Board") else null
@onready var _hud: HUD = $HUD if has_node("HUD") else null
@onready var _pause_overlay: PauseOverlay = $PauseOverlay if has_node("PauseOverlay") else null

var _level_id: int = 1
var _mode: String = "campaign"

func _ready() -> void:
	if has_node("/root/SceneRouter"):
		var args: Dictionary = get_node("/root/SceneRouter").current_args
		_level_id = int(args.get("level_id", 1))
		_mode = str(args.get("mode", "campaign" if _level_id > 0 else "endless"))

	if _hud != null:
		_hud.pause_requested.connect(_on_pause_requested)

	if _pause_overlay != null:
		_pause_overlay.restarted.connect(_restart_level)
		_pause_overlay.quit_to_map.connect(_quit_to_map)

	if _board != null and _hud != null:
		_board.rat_bonked.connect(func(_id, pts, pos): _hud.show_score_popup(pts, pos))

	if has_node("/root/Game"):
		var g: Node = get_node("/root/Game")
		if not g.level_ended.is_connected(_on_level_ended):
			g.level_ended.connect(_on_level_ended)

	_start_gameplay()

func _start_gameplay() -> void:
	if not has_node("/root/Game") or _board == null:
		return

	var g: Node = get_node("/root/Game")
	if _mode == "endless" or _level_id == 0:
		g.start_endless()
		if has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_music("endless")
		var endless_iv := func(p: float) -> float:
			var wave_speed := 1.0 + 0.12 * float(g.endless_wave() - 1)
			return g.cfg.interval_at(p) / wave_speed
		_board.setup(g.cfg, endless_iv)
	else:
		var path := "res://src/data/levels/level_%02d.tres" % _level_id
		var cfg: LevelConfig = load(path) if ResourceLoader.exists(path) else null
		if cfg != null:
			g.start_level(cfg)
			if has_node("/root/AudioManager"):
				get_node("/root/AudioManager").play_music(cfg.music_track)
			_board.setup(cfg, cfg.interval_at)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause()

func _toggle_pause() -> void:
	if _pause_overlay == null:
		return
	if get_tree().paused:
		_pause_overlay.hide_pause()
	else:
		_pause_overlay.show_pause()

func _on_pause_requested() -> void:
	if _pause_overlay != null:
		_pause_overlay.show_pause()

func _restart_level() -> void:
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").goto("res://src/game/game_screen.tscn", {"level_id": _level_id, "mode": _mode})

func _quit_to_map() -> void:
	if has_node("/root/SceneRouter"):
		if _mode == "endless":
			get_node("/root/SceneRouter").goto("res://src/screens/main_menu.tscn")
		else:
			get_node("/root/SceneRouter").goto("res://src/screens/zone_map.tscn")

func _on_level_ended(result: Dictionary) -> void:
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		if has_node("/root/SceneRouter"):
			if _mode == "endless" or _level_id == 0:
				get_node("/root/SceneRouter").goto("res://src/screens/endless_results.tscn", result)
			else:
				get_node("/root/SceneRouter").goto("res://src/screens/results.tscn", result)
	)
