class_name Synth
extends RefCounted

const SAMPLE_RATE := 44100

static func buffer(seconds: float) -> PackedFloat32Array:
	var count := int(seconds * SAMPLE_RATE)
	var buf := PackedFloat32Array()
	buf.resize(count)
	buf.fill(0.0)
	return buf

static func env_adsr(i: int, n: int, attack_s: float, release_s: float) -> float:
	if n <= 0:
		return 0.0
	var a_samples := int(attack_s * SAMPLE_RATE)
	var r_samples := int(release_s * SAMPLE_RATE)
	var env := 1.0
	if a_samples > 0 and i < a_samples:
		env = float(i) / float(a_samples)
	if r_samples > 0 and i >= n - r_samples:
		var r_idx := float(n - 1 - i) / float(r_samples)
		env = minf(env, clampf(r_idx, 0.0, 1.0))
	return env

static func osc(
	buf: PackedFloat32Array,
	freq: Variant,
	wave: String = "sine",
	amp: float = 1.0,
	attack_s: float = 0.0,
	release_s: float = 0.0
) -> PackedFloat32Array:
	mix_osc(buf, 0.0, float(buf.size()) / float(SAMPLE_RATE), freq, wave, amp, attack_s, release_s)
	return buf

static func mix_osc(
	buf: PackedFloat32Array,
	start_s: float,
	dur_s: float,
	freq: Variant,
	wave: String = "sine",
	amp: float = 1.0,
	attack_s: float = 0.01,
	release_s: float = 0.02
) -> void:
	var start_idx := int(start_s * SAMPLE_RATE)
	var sample_count := int(dur_s * SAMPLE_RATE)
	var phase := 0.0
	var two_pi := TAU

	for i in range(sample_count):
		var target_idx := start_idx + i
		if target_idx < 0:
			continue
		if target_idx >= buf.size():
			break
		var t := float(i) / float(SAMPLE_RATE)
		var f: float = 440.0
		if freq is Callable:
			f = float(freq.call(t))
		elif freq is float or freq is int:
			f = float(freq)

		var val := 0.0
		match wave:
			"sine":
				val = sin(phase)
			"square":
				val = 1.0 if sin(phase) >= 0.0 else -1.0
			"saw":
				var norm_p := fposmod(phase / two_pi, 1.0)
				val = 2.0 * norm_p - 1.0
			"tri":
				var norm_p := fposmod(phase / two_pi, 1.0)
				val = 2.0 * absf(2.0 * norm_p - 1.0) - 1.0
			"noise":
				val = randf_range(-1.0, 1.0)
			_:
				val = sin(phase)

		var env := env_adsr(i, sample_count, attack_s, release_s)
		buf[target_idx] += val * amp * env

		phase += two_pi * f / float(SAMPLE_RATE)
		if phase > two_pi:
			phase = fposmod(phase, two_pi)

static func tone(
	freq_hz: float,
	seconds: float,
	wave: String = "sine",
	amp: float = 0.8,
	slide_to: float = 0.0
) -> PackedFloat32Array:
	var buf := buffer(seconds)
	var freq_fn: Callable
	if slide_to > 0.0:
		freq_fn = func(t: float) -> float:
			return lerpf(freq_hz, slide_to, clampf(t / seconds, 0.0, 1.0))
	else:
		freq_fn = func(_t: float) -> float:
			return freq_hz
	return osc(buf, freq_fn, wave, amp, 0.005, 0.02)

static func normalize(buf: PackedFloat32Array, peak: float = 0.85) -> PackedFloat32Array:
	var max_val := 0.0
	for s in buf:
		var abs_s := absf(s)
		if abs_s > max_val:
			max_val = abs_s
	if max_val > 0.0001:
		var scale := peak / max_val
		for i in range(buf.size()):
			buf[i] *= scale
	return buf

static func save_wav(buf: PackedFloat32Array, path: String) -> Error:
	var byte_count := buf.size() * 2
	var bytes := PackedByteArray()
	bytes.resize(byte_count)

	for i in range(buf.size()):
		var sample := int(clampf(buf[i], -1.0, 1.0) * 32767.0)
		var u_sample := sample if sample >= 0 else (sample + 65536)
		bytes[i * 2] = u_sample & 0xFF
		bytes[i * 2 + 1] = (u_sample >> 8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes

	var global_path := ProjectSettings.globalize_path(path)
	var dir := global_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)

	return wav.save_to_wav(path)
