extends SceneTree

const Synth := preload("res://tools/synth.gd")

func _initialize() -> void:
	print("Generating SFX audio library...")
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	_gen_sfx()
	print("Audio generation complete.")
	quit(0)

func _gen_sfx() -> void:
	# 1. bonk: sine thump sliding 180->54 Hz over 0.15s + short noise burst overlay
	var b_bonk := Synth.buffer(0.15)
	Synth.mix_osc(b_bonk, 0.0, 0.15, func(t): return lerpf(180.0, 54.0, t / 0.15), "sine", 0.85, 0.002, 0.08)
	Synth.mix_osc(b_bonk, 0.0, 0.04, 1000.0, "noise", 0.25, 0.001, 0.035)
	Synth.normalize(b_bonk, 0.9)
	Synth.save_wav(b_bonk, "res://assets/audio/bonk.wav")

	# 2. bonk_heavy: sine thump sliding 120->36 Hz over 0.22s + short noise burst overlay
	var b_heavy := Synth.buffer(0.22)
	Synth.mix_osc(b_heavy, 0.0, 0.22, func(t): return lerpf(120.0, 36.0, t / 0.22), "sine", 0.9, 0.003, 0.12)
	Synth.mix_osc(b_heavy, 0.0, 0.06, 800.0, "noise", 0.35, 0.002, 0.05)
	Synth.normalize(b_heavy, 0.9)
	Synth.save_wav(b_heavy, "res://assets/audio/bonk_heavy.wav")

	# 3. squeak: square chirp 900->1500 Hz, 0.12s
	var b_sq := Synth.buffer(0.12)
	Synth.mix_osc(b_sq, 0.0, 0.12, func(t): return lerpf(900.0, 1500.0, t / 0.12), "square", 0.35, 0.01, 0.03)
	Synth.normalize(b_sq, 0.8)
	Synth.save_wav(b_sq, "res://assets/audio/squeak.wav")

	# 4. whiff: noise sweep over 0.18s
	var b_whiff := Synth.buffer(0.18)
	Synth.mix_osc(b_whiff, 0.0, 0.18, 2000.0, "noise", 0.6, 0.02, 0.14)
	Synth.normalize(b_whiff, 0.75)
	Synth.save_wav(b_whiff, "res://assets/audio/whiff.wav")

	# 5. yowl: two detuned saws sliding 500->240 Hz, 0.45s
	var b_yowl := Synth.buffer(0.45)
	Synth.mix_osc(b_yowl, 0.0, 0.45, func(t): return lerpf(500.0, 240.0, t / 0.45), "saw", 0.45, 0.02, 0.1)
	Synth.mix_osc(b_yowl, 0.0, 0.45, func(t): return lerpf(508.0, 244.0, t / 0.45), "saw", 0.45, 0.02, 0.1)
	Synth.normalize(b_yowl, 0.85)
	Synth.save_wav(b_yowl, "res://assets/audio/yowl.wav")

	# 6. boom: sub sine 90->30 Hz 0.6s + descending noise 0.5s
	var b_boom := Synth.buffer(0.6)
	Synth.mix_osc(b_boom, 0.0, 0.6, func(t): return lerpf(90.0, 30.0, t / 0.6), "sine", 0.7, 0.01, 0.35)
	Synth.mix_osc(b_boom, 0.0, 0.5, 500.0, "noise", 0.5, 0.005, 0.4)
	Synth.normalize(b_boom, 0.9)
	Synth.save_wav(b_boom, "res://assets/audio/boom.wav")

	# 7. freeze_chime: overlapping triad/arpeggio tri notes (E5, G#5, B5, E6)
	var b_freeze := Synth.buffer(0.4)
	var f_notes := [659.25, 830.61, 987.77, 1318.51]
	for idx in range(f_notes.size()):
		Synth.mix_osc(b_freeze, idx * 0.06, 0.20, f_notes[idx], "tri", 0.5, 0.01, 0.12)
	Synth.normalize(b_freeze, 0.85)
	Synth.save_wav(b_freeze, "res://assets/audio/freeze_chime.wav")

	# 8. star_pickup: upward arpeggio tri notes (C5, E5, G5, C6)
	var b_star := Synth.buffer(0.35)
	var s_notes := [523.25, 659.25, 783.99, 1046.50]
	for idx in range(s_notes.size()):
		Synth.mix_osc(b_star, idx * 0.05, 0.18, s_notes[idx], "tri", 0.5, 0.01, 0.10)
	Synth.normalize(b_star, 0.85)
	Synth.save_wav(b_star, "res://assets/audio/star_pickup.wav")

	# 9-13. combo_1..5: tri chimes with increasing pitch
	var combo_bases := [0, 3, 5, 7, 12]
	for c_idx in range(5):
		var semi: int = combo_bases[c_idx]
		var f1 := 440.0 * pow(2.0, float(semi) / 12.0)
		var f2 := 440.0 * pow(2.0, float(semi + 7) / 12.0)
		var b_combo := Synth.buffer(0.25)
		Synth.mix_osc(b_combo, 0.0, 0.22, f1, "tri", 0.5, 0.01, 0.12)
		Synth.mix_osc(b_combo, 0.02, 0.22, f2, "tri", 0.4, 0.01, 0.12)
		Synth.normalize(b_combo, 0.85)
		Synth.save_wav(b_combo, "res://assets/audio/combo_%d.wav" % (c_idx + 1))

	# 14. star_fanfare: C-major stack up an octave
	var b_fanfare := Synth.buffer(0.7)
	var fan_notes := [523.25, 659.25, 783.99, 1046.50, 1318.51]
	for idx in range(fan_notes.size()):
		Synth.mix_osc(b_fanfare, idx * 0.08, 0.35, fan_notes[idx], "tri", 0.45, 0.01, 0.2)
	Synth.normalize(b_fanfare, 0.85)
	Synth.save_wav(b_fanfare, "res://assets/audio/star_fanfare.wav")

	# 15. ui_click: 1200 Hz square blip 50 ms
	var b_click := Synth.buffer(0.05)
	Synth.mix_osc(b_click, 0.0, 0.05, 1200.0, "square", 0.4, 0.005, 0.02)
	Synth.normalize(b_click, 0.75)
	Synth.save_wav(b_click, "res://assets/audio/ui_click.wav")

	# 16. ui_back: 600 Hz square blip 70 ms
	var b_back := Synth.buffer(0.07)
	Synth.mix_osc(b_back, 0.0, 0.07, 600.0, "square", 0.4, 0.005, 0.03)
	Synth.normalize(b_back, 0.75)
	Synth.save_wav(b_back, "res://assets/audio/ui_back.wav")

	# 17. level_win: rising C-major arpeggio squares x5 across 0.9s
	var b_win := Synth.buffer(0.9)
	var win_notes := [261.63, 329.63, 392.00, 523.25, 659.25]
	for idx in range(win_notes.size()):
		Synth.mix_osc(b_win, idx * 0.12, 0.35, win_notes[idx], "square", 0.3, 0.01, 0.18)
	Synth.normalize(b_win, 0.85)
	Synth.save_wav(b_win, "res://assets/audio/level_win.wav")

	# 18. level_fail: three falling saw tones (G4->F#4->D#4) over 1.0s
	var b_fail := Synth.buffer(1.0)
	var fail_notes := [392.00, 369.99, 311.13]
	for idx in range(fail_notes.size()):
		Synth.mix_osc(b_fail, idx * 0.25, 0.45, fail_notes[idx], "saw", 0.4, 0.02, 0.25)
	Synth.normalize(b_fail, 0.85)
	Synth.save_wav(b_fail, "res://assets/audio/level_fail.wav")
