class_name SettingsScreen
extends Control
## Settings screen configuring audio volumes, screen shake and save data reset.

@onready var _back_btn: Button = $Header/BackBtn
@onready var _music_slider: HSlider = $Content/VBox/MusicRow/MusicSlider
@onready var _music_val_lbl: Label = $Content/VBox/MusicRow/MusicVal
@onready var _sfx_slider: HSlider = $Content/VBox/SfxRow/SfxSlider
@onready var _sfx_val_lbl: Label = $Content/VBox/SfxRow/SfxVal
@onready var _shake_check: CheckButton = $Content/VBox/ShakeRow/ShakeCheck
@onready var _reset_btn: Button = $Content/VBox/ResetBtn
@onready var _status_lbl: Label = $Content/VBox/StatusLabel

func _ready() -> void:
	if _back_btn != null:
		_back_btn.pressed.connect(_on_back_pressed)

	if has_node("/root/Settings"):
		var s: Node = get_node("/root/Settings")
		if _music_slider != null:
			_music_slider.value = s.music_volume * 100.0
			_update_music_label(s.music_volume)
			_music_slider.value_changed.connect(_on_music_changed)

		if _sfx_slider != null:
			_sfx_slider.value = s.sfx_volume * 100.0
			_update_sfx_label(s.sfx_volume)
			_sfx_slider.value_changed.connect(_on_sfx_changed)

		if _shake_check != null:
			_shake_check.button_pressed = s.shake_enabled
			_shake_check.toggled.connect(_on_shake_toggled)

	if _reset_btn != null:
		_reset_btn.pressed.connect(_on_reset_pressed)

func _on_music_changed(val: float) -> void:
	var v := val / 100.0
	_update_music_label(v)
	if has_node("/root/Settings"):
		get_node("/root/Settings").set_music_volume(v)

func _update_music_label(v: float) -> void:
	if _music_val_lbl != null:
		_music_val_lbl.text = "%d%%" % int(v * 100.0)

func _on_sfx_changed(val: float) -> void:
	var v := val / 100.0
	_update_sfx_label(v)
	if has_node("/root/Settings"):
		get_node("/root/Settings").set_sfx_volume(v)

func _update_sfx_label(v: float) -> void:
	if _sfx_val_lbl != null:
		_sfx_val_lbl.text = "%d%%" % int(v * 100.0)

func _on_shake_toggled(pressed: bool) -> void:
	if has_node("/root/Settings"):
		get_node("/root/Settings").set_shake_enabled(pressed)

func _on_reset_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").reset_all()
	if _status_lbl != null:
		_status_lbl.text = "Save data reset to fresh state!"
		_status_lbl.visible = true

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx("ui_back")
	if has_node("/root/SceneRouter"):
		get_node("/root/SceneRouter").back()
