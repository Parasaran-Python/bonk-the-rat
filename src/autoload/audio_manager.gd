extends Node
## Audio playback singleton managing SFX pooling and music streaming.

const POOL_SIZE := 8
const SFX_DIR := "res://assets/audio"

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0
var _sfx_cache: Dictionary = {}

func _ready() -> void:
	_make_buses()
	_init_sfx_pool()

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

func play_sfx(name: String, pitch_jitter: float = 0.06) -> void:
	var stream := _get_sfx_stream(name)
	if stream == null:
		return

	if _sfx_players.is_empty():
		_init_sfx_pool()

	# Pick round-robin player
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

func play_music(_track: String) -> void:
	# Wired in Task 9
	pass

func stop_music(_fade: float = 1.0) -> void:
	# Wired in Task 9
	pass
