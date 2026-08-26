extends TestCase

func test_roundtrip() -> void:
	var d := SaveStore.default_data()
	d = SaveStore.award_stars(d, 1, 2)
	d = SaveStore.record_best(d, 1, 1234)
	d = SaveStore.mark_tutorial_seen(d)
	var back := SaveStore.deserialize(SaveStore.serialize(d))
	ok(not back.is_empty(), "parses")
	eq(int(back.stars[1]), 2, "stars survive")
	eq(int(back.best_scores[1]), 1234, "best survives")
	ok(back.tutorial_seen, "flag survives")

func test_deserialize_rejects_garbage() -> void:
	ok(SaveStore.deserialize("not json {{{").is_empty(), "garbage rejected")
	ok(SaveStore.deserialize("{\"wrong\":1}").is_empty(), "missing schema rejected")

func test_award_stars_max_wins() -> void:
	var d := SaveStore.default_data()
	d = SaveStore.award_stars(d, 3, 1)
	d = SaveStore.award_stars(d, 3, 3)
	eq(int(d.stars[3]), 3, "max kept")

func test_top_ten_sorted_and_capped() -> void:
	var d := SaveStore.default_data()
	for i in range(15):
		d = SaveStore.submit_endless(d, "AAA", 100 + i * 10)
	eq(d.endless_top10.size(), 10, "capped at 10")
	eq(int(d.endless_top10[0].score), 240, "highest first")

func test_manager_corruption_recovers() -> void:
	var tag := str(Time.get_ticks_msec())
	var path := "user://test_save_%s.cfg" % tag
	var mgr: Node = load("res://src/autoload/save_manager.gd").new()
	mgr.SAVE_PATH = path
	mgr.load_or_init()
	mgr.set_result(1, 500, 2)
	mgr.save_now()
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("CORRUPTED JUNK")
	f = null
	var mgr2: Node = load("res://src/autoload/save_manager.gd").new()
	mgr2.SAVE_PATH = path
	mgr2.load_or_init()
	eq(mgr2.get_stars(1), 0, "fresh defaults after corruption")
	ok(FileAccess.file_exists(path + ".bak"), "backup kept")
