extends SceneTree
## godot --headless --path . --script tests/run.gd   Exit 0 = green.

func _initialize() -> void:
	var autoloads := {
		"Settings": "res://src/autoload/settings.gd",
		"SaveManager": "res://src/autoload/save_manager.gd",
		"AudioManager": "res://src/autoload/audio_manager.gd",
		"Game": "res://src/autoload/game.gd",
	}
	for k in autoloads:
		if not root.has_node(k):
			var n: Node = load(autoloads[k]).new()
			n.name = k
			root.add_child(n)

	var failures := 0
	var total_checks := 0
	for path in _discover("res://tests"):
		var mod: Object = load(path).new()
		mod.set("root", root)
		mod.set("tree", self)
		for m in mod.get_method_list():
			if not m.name.begins_with("test_"):
				continue
			mod.errors.clear()
			mod.checks = 0
			mod.call(m.name)
			total_checks += mod.checks
			if not mod.errors.is_empty():
				failures += 1
				print("FAIL %s :: %s" % ["%s:%s" % [path.get_file(), m.name], "; ".join(mod.errors)])
	print("%d checks, %d failing cases" % [total_checks, failures])
	quit(1 if failures > 0 else 0)

func _discover(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir_path)
	if d == null:
		return out
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if f.ends_with(".gd") and f != "test_case.gd" and f != "run.gd":
			out.append(dir_path + "/" + f)
		f = d.get_next()
	out.sort()
	return out
