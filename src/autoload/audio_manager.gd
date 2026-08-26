extends Node
## Audio playback singleton managing SFX pooling, music streaming and volume routing.

const POOL_SIZE := 8
const SFX_DIR := "res://assets/audio"

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0
var _sfx_cache: Dictionary = {}

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_current: AudioStreamPlayer = null
var _current_track_name := ""
var _music_tween: Tween = null

func _ready() -> void:
	_make_buses()
	_init_sfx_pool()
	_init_music_players()
	_wire_settings()
	_apply_volumes()

func _make_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, "Music")
		AudioServer.set_bus_send(idx, "Master")

	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, "SFX")
		AudioServer.set_bus_send(idx, "Master")

func _init_sfx_pool() -> void:
	_sfx_players.clear()
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

func _init_music_players() -> void:
	_music_a = AudioStreamPlayer.new()
	_music_a.name = "MusicPlayer_A"
	_music_a.bus = "Music"
	add_child(_music_a)

	_music_b = AudioStreamPlayer.new()
	_music_b.name = "MusicPlayer_B"
	_music_b.bus = "Music"
	add_child(_music_b)

func _wire_settings() -> void:
	if has_node("/root/Settings"):
		var settings: Node = get_node("/root/Settings")
		if settings.has_signal("changed") and not settings.changed.is_connected(_apply_volumes):
			settings.changed.connect(_apply_volumes)

func _apply_volumes() -> void:
	var sfx_vol := 1.0
	var music_vol := 0.8
	if has_node("/root/Settings"):
		var settings: Node = get_node("/root/Settings")
		sfx_vol = settings.sfx_volume
		music_vol = settings.music_volume

	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		var db := linear_to_db(sfx_vol) if sfx_vol > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(sfx_idx, db)

	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		var db := linear_to_db(music_vol) if music_vol > 0.0001 else -80.0
		AudioServer.set_bus_volume_db(music_idx, db)

func play_sfx(name: String, pitch_jitter: float = 0.06) -> void:
	var stream := _get_sfx_stream(name)
	if stream == null:
		return

	if _sfx_players.is_empty():
		_init_sfx_pool()

	var player: AudioStreamPlayer = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()

	player.stream = stream
	if pitch_jitter > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	else:
		player.pitch_scale = 1.0
	player.play()

func _get_sfx_stream(name: String) -> AudioStream:
	if _sfx_cache.has(name):
		return _sfx_cache[name]

	var path := "%s/%s.wav" % [SFX_DIR, name]
	if ResourceLoader.exists(path):
		var s: AudioStream = load(path)
		_sfx_cache[name] = s
		return s
	return null

func play_music(track: String) -> void:
	if track == _current_track_name and _music_current != null and _music_current.playing:
		return

	_current_track_name = track
	var path := "%s/music_%s.wav" % [SFX_DIR, track]
	if not ResourceLoader.exists(path):
		return

	var stream: AudioStream = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = stream.data.size() / 2

	if _music_a == null or _music_b == null:
		_init_music_players()

	var target_player := _music_b if _music_current == _music_a else _music_a
	var outgoing_player := _music_current

	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()

	target_player.stream = stream
	target_player.volume_db = -80.0
	target_player.play()
	_music_current = target_player

	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(target_player, "volume_db", 0.0, 0.8)
	if outgoing_player != null and outgoing_player.playing:
		_music_tween.tween_property(outgoing_player, "volume_db", -80.0, 0.8)
		_music_tween.chain().tween_callback(outgoing_player.stop)

func stop_music(fade: float = 1.0) -> void:
	_current_track_name = ""
	if _music_current == null or not _music_current.playing:
		return

	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()

	if fade <= 0.0:
		_music_current.stop()
		_music_current.volume_db = 0.0
		return

	var p := _music_current
	_music_tween = create_tween()
	_music_tween.tween_property(p, "volume_db", -80.0, fade)
	_music_tween.tween_callback(p.stop)
