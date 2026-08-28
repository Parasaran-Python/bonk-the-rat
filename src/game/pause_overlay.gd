class_name PauseOverlay
extends CanvasLayer
## Modal pause screen handling resume, restart and quit actions.

signal resumed()
signal restarted()
signal quit_to_map()

@onready var _resume_btn: Button = $Root/Panel/VBox/ResumeBtn if has_node("Root/Panel/VBox/ResumeBtn") else ($Panel/VBox/ResumeBtn if has_node("Panel/VBox/ResumeBtn") else find_child("ResumeBtn"))
@onready var _restart_btn: Button = $Root/Panel/VBox/RestartBtn if has_node("Root/Panel/VBox/RestartBtn") else ($Panel/VBox/RestartBtn if has_node("Panel/VBox/RestartBtn") else find_child("RestartBtn"))
@onready var _quit_btn: Button = $Root/Panel/VBox/QuitBtn if has_node("Root/Panel/VBox/QuitBtn") else ($Panel/VBox/QuitBtn if has_node("Panel/VBox/QuitBtn") else find_child("QuitBtn"))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if _resume_btn != null:
		_resume_btn.pressed.connect(_on_resume)
	if _restart_btn != null:
		_restart_btn.pressed.connect(_on_restart)
	if _quit_btn != null:
		_quit_btn.pressed.connect(_on_quit)

func show_pause() -> void:
	if is_inside_tree():
		get_tree().paused = true
	visible = true

func hide_pause() -> void:
	if is_inside_tree():
		get_tree().paused = false
	visible = false

func _on_resume() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	hide_pause()
	resumed.emit()

func _on_restart() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_click")
	hide_pause()
	restarted.emit()

func _on_quit() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	hide_pause()
	quit_to_map.emit()
